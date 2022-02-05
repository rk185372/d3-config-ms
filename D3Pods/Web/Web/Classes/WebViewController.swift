//
//  WebViewController.swift
//  D3 Banking
//
//  Created by David McRae on 5/31/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import AppConfiguration
import UIKit
import Network
import WebKit
import ComponentKit
import Localization
import Utilities
import SnapKit
import Biometrics
import RxSwift
import Session
import Messages
import Logging
import Analytics
import InAppRatingApi
import D3Contacts
import CardControlApi
import LocalizationData
import FIS
import QRScanner

public enum WebViewControllerError: Error {
    case bridgeCallTimeout
    case nilSessionOnBridgeCall
}

public enum WebBridgeError: Error {
     case generic
}

public class WebViewController: UIViewControllerComponent {
    @IBOutlet weak var progressView: UIProgressView!

    // This serial queue ensures that 2 webviews cannot emit user profile changes at the same time,
    // which allows a webview to safely ignore updates while it is emitting.
    private static let emitQueue = DispatchQueue(label: "\(type(of: self)).emitQueue")

    private let webClient: WebClient
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let pdfPresenter: PDFPresenter
    private let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftArrow"), style: .plain, target: nil, action: nil)
    private let urlOpener: URLOpener
    private let messageStatsManager: MessageStatsManager
    private let webViewExtensionsCache: WebViewExtensionsCache
    private let analyticsTracker: AnalyticsTracker
    private let inAppRatingManager: InAppRatingManager
    private let profileIconCoordinatorFactory: ProfileIconCoordinatorFactory
    private let profileIconCoordinator: ProfileIconCoordinator
    private let contactsHelper: ContactsHelper
    private let isModal: Bool
    private let webProcessPool: WKProcessPool
    private let cardControl: CardControlManager
    private let webClientFactory: WebClientFactory
    private let qrScannerFactory: QRScannerViewControllerFactory
    private let qrScannerPresenter: QRScannerPresenter
    private let userDefaults = UserDefaults(suiteName: AppConfiguration.applicationGroup)!

    private var isRootComponent: Bool = false
    private var isLoaded: Bool = false
    private var emitting = false
    private var webView: WKWebView!
    
    private var cookies: [HTTPCookie]
    
    private var bridgeCallTimeoutSubscription: Disposable!
    private var sessionHandoffSubscription: Disposable!
    private var cookieSettingDelaySubscription: Disposable!

    private var originalPickerDelgate: UIPickerViewDelegate?
    private var pickerRowHeight: CGFloat = 25
    
    private var previousViewController: UIViewController? {
        if let viewControllers = navigationController?.viewControllers, viewControllers.count > 1 {
            return viewControllers[viewControllers.endIndex - 2]
        }
        return nil
    }
    
    private var postDismissAction: (() -> Void)?
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                webClient: WebClient,
                isRootComponent: Bool,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory,
                pdfPresenter: PDFPresenter,
                urlOpener: URLOpener,
                messageStatsManager: MessageStatsManager,
                webViewExtensionsCache: WebViewExtensionsCache,
                analyticsTracker: AnalyticsTracker,
                inAppRatingManager: InAppRatingManager,
                profileIconCoordinatorFactory: ProfileIconCoordinatorFactory,
                isModal: Bool = false,
                webProcessPool: WKProcessPool,
                cardControl: CardControlManager,
                webClientFactory: WebClientFactory,
                qrScannerFactory: QRScannerViewControllerFactory,
                postDismissAction: (() -> Void)? = nil) {
        
        self.webClient = webClient
        self.isRootComponent = isRootComponent
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.pdfPresenter = pdfPresenter
        self.urlOpener = urlOpener
        self.messageStatsManager = messageStatsManager
        self.webViewExtensionsCache = webViewExtensionsCache
        self.analyticsTracker = analyticsTracker
        self.inAppRatingManager = inAppRatingManager
        self.profileIconCoordinatorFactory = profileIconCoordinatorFactory
        self.isModal = isModal
        self.profileIconCoordinator = profileIconCoordinatorFactory.create()
        self.contactsHelper = ContactsHelper()
        self.webProcessPool = webProcessPool
        self.cardControl = cardControl
        self.webClientFactory = webClientFactory
        self.qrScannerFactory = qrScannerFactory
        self.qrScannerPresenter = QRScannerPresenter(webClient: webClient,
                                                     qrScannerFactory: qrScannerFactory,
                                                     l10nProvider: l10nProvider)
        self.postDismissAction = postDismissAction
        
        self.cookies = Array()
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider:
            componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: WebBundle.bundle
        )

        backButton.target = self
        backButton.action = #selector(backButtonTapped)
        backButton.accessibilityLabel = l10nProvider.localize("app.nav.backButton.accessibilityLabel")
        backButton.accessibilityTraits = UIAccessibilityTraits.button
        navigationItem.accessibilityLabel = navigationItem.title

        contactsHelper
            .selectedContactProperty
            .subscribe(onNext: { [unowned self] result in
                if let json = result.json {
                    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    switch result.mode {
                    case .zelle:
                        self.resolvePromise(id: result.promiseId, withString: jsonString)
                    case .fiserv:
                        // Not supported for WebViewController
                        break
                    }
                } else {
                    self.resolvePromise(id: result.promiseId)
                }
            })
            .disposed(by: bag)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sectionRequiresUpdateNotification(notification:)),
            name: .sectionRequiresUpdateNotification,
            object: nil
        )
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        if !isRootComponent {
            navigationItem.leftBarButtonItem = backButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        let webSiteDataStore = WKWebsiteDataStore.default()
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = webSiteDataStore
        configuration.processPool = self.webProcessPool
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        self.createWebView(configuration: configuration)
        self.setupBridgeCallTimeoutSubscriptions()

        addCookies(toDataStore: webSiteDataStore) {
            self.cookieSettingDelaySubscription = Observable<Int>
                .interval(.milliseconds(500), scheduler: MainScheduler.instance)
                .take(1)
                .subscribe({ [unowned self] _ in
                    self.loadUrl()
                    self.subscribeToSessionChanges()
                })
            self.cookieSettingDelaySubscription.disposed(by: self.bag)
        }

        if isModal {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "CloseButton"),
                style: .plain,
                target: self,
                action: #selector(doneButtonTouched)
            )
        } else if webClient.componentPath.showsUserProfile {
            setupProfileIcon()
        }

        self.cardControl
            .errorRelay
            .skip(1)
            .subscribe(onNext: { [weak self](error) in
                switch error {
                case .launch(let message), .initialize(let message):
                    self?.showErrorAlert(message: message)
                default:
                    break
                }
            }).disposed(by: bag)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotifications()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(
            notification: UIAccessibility.Notification.screenChanged,
            argument: self.backButton
        )
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isTabSwitchingAllowed = UITabBarControllerComponent.switchingAllowedDictionary["isTabSwitchingAllowed"]
            as? Bool, isTabSwitchingAllowed {
            NotificationCenter.default.removeObserver(self, name: .stopTabSwitchNotification, object: nil)
        }
        removeNotifications()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postDismissAction?()
    }
    
    private func addCookies(toDataStore webSiteDataStore: WKWebsiteDataStore, completion: @escaping () -> Void) {
        let baseDomain = Domain(domain: webClient.domain.host ?? "")
        cookies = HTTPCookieStorage.shared.cookies!.filter { (cookie) -> Bool in
            let cookieDomain = Domain(domain: cookie.domain)
            return cookieDomain.isSubdomain(ofDomain: baseDomain)
        }
        
        log.debug("Configuring with \(cookies.count) cookies")
        webSiteDataStore.httpCookieStore.set(cookies: self.cookies, completion: completion)
    }

    private func createWebView(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(webView, at: 0)

        let safeArea = view.safeAreaLayoutGuide
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: tabBarHeight)
        ])
        webView.scrollView.contentInset.bottom = tabBarHeight
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
#if DEBUG
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
#endif
        
        // WKUserContentController retains a strong reference to its handlers, so to avoid a retain
        // cycle, we wrap `self` with a weak reference.
        let handler = WeakScriptMessageHandler(around: self)

        // See http://igomobile.de/2017/03/06/wkwebview-return-a-value-from-native-code-to-javascript/
        // for info on how messaging works. The web side lives in src/util/device.ts in web-sdk.
        for message in WebToNativeMessage.allCases {
            webView.configuration.userContentController.add(handler, name: message.rawValue)
        }
        
        webView
            .rx
            .url
            .subscribe(onNext: { [unowned self] (url) in
                let trimmedUrl = url
                    .absoluteString
                    .drop { $0 != "#" }
                    .lowercased()
                if (trimmedUrl == "#alerts" || trimmedUrl.contains("#alerts/")) {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(
                        image: UIImage(named: "CogButton"),
                        style: .plain,
                        target: self,
                        action: #selector(cogButtonTouched)
                    )
                }
                
                if (trimmedUrl  == "#alert-management" && navigationItem.rightBarButtonItem?.image == UIImage(named: "CogButton")) {
                    navigationItem.rightBarButtonItem = nil
                }

                self.analyticsTracker.trackScreen("\(trimmedUrl)")
            })
            .disposed(by: bag)

        webView
            .rx
            .canGoBack
            .subscribe(onNext: { [unowned self] (canGoBack) in
                self.navigationItem.leftBarButtonItem = (canGoBack || !self.isRootComponent)
                    ? self.backButton
                    : nil
            })
            .disposed(by: bag)

        webView
            .rx
            .estimatedProgress
            .subscribe(onNext: { [weak self] (progress) in
                guard let self = self else { return }
                self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies({ cookies in
                    log.debug("Web view has \(cookies.count) cookies")

                    if !self.allNativeCookiesExistInWeb(nativeCookies: self.cookies, webCookies: cookies) {
                        self.cookies.forEach({ cookie in
                            guard let cookie2 = HTTPCookie.init(properties: cookie.properties!) else {
                               return
                            }
                            self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie2) {
                                log.debug("cookie has been reset")
                            }
                        })
                    }
                })
                self.progressView.setProgress(Float(progress), animated: true)
            })
            .disposed(by: bag)
        
        webView
            .rx
            .isLoading
            .subscribe(onNext: { [unowned self] (isLoading) in
                self.progressView.isHidden = !isLoading
                if isLoading {
                    log.debug("WebViewController start loading")
                } else {
                    log.debug("WebViewController finished loading")
                    self.webView.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 0, height: 0), animated: false)
                }
            })
            .disposed(by: bag)
        
        webView
            .rx
            .title
            .subscribe(onNext: { [unowned self] (title) in
                self.navigationItem.title = title
                UIAccessibility.post(
                    notification: UIAccessibility.Notification.screenChanged,
                    argument: self.navigationItem.title
                )
            })
            .disposed(by: bag)
        
        FISConnector().connect(to: webView)
    }
    
    // Normally we could compare these two sets of Cookies with a Set
    // with something like - if !nativeCookieSet.isSubset(of: webCookieSet) {
    // but currently the app cookies are version 0 and the web cookies are version 1
    // making a Set comparison not possible
    private func allNativeCookiesExistInWeb(nativeCookies: [HTTPCookie], webCookies: [HTTPCookie]) -> Bool {
        var foundAll = true
        
        nativeCookies.forEach({ nativeCookie in
            if webCookies.filter({ $0.name == nativeCookie.name && $0.value == nativeCookie.value }).isEmpty {
                // found a missing cookie
                log.debug("\(nativeCookie.name) was found missing in the web")
                foundAll = false
            }
        })
        
        return foundAll
    }
    
    private func subscribeToSessionChanges() {
        for (index, observable) in webClient.userSession.rx.userProfiles.enumerated() {
            observable
                .distinctUntilChanged()
                .skip(1)
                .skipNil()
                .filter { [unowned self] _ in !self.emitting }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (userProfile) in
                    self.send(message: .updateUserProfile(userProfile: userProfile, index: index))
                })
                .disposed(by: self.bag)
        }

        webClient.userSession.rx.selectedProfileIndex
            .distinctUntilChanged()
            .skip(1)
            .skipNil()
            .filter { [unowned self] _ in !self.emitting }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (index) in
                log.debug("WebViewController: \(self) reacting to profile, change popping back to root")
                self.send(message: .selectProfile(index: index))
                self.navigationController?.popToRootViewController(animated: false)
            })
            .disposed(by: bag)
    }

    private func setupBridgeCallTimeoutSubscriptions() {
        bridgeCallTimeoutSubscription = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                log.error(
                    "Web failed to make session bridge call before timeout",
                    context: WebViewControllerError.bridgeCallTimeout
                )

                guard let self = self else { return }
                // If the timer runs out of time to make the session bridge call
                // then the check for nil session will never happen and that timer won't
                // be disposed of making it look like the session was nil when it wasn't
                // To fix this, We want to go ahead and dispose of the nil session
                // handoff subscription since we know that it will never be
                // disposed of. If the bridge call is never made.
                self.sessionHandoffSubscription.dispose()
            })
        bridgeCallTimeoutSubscription.disposed(by: bag)

        sessionHandoffSubscription = Observable<Int>
            .interval(.seconds(6), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { _ in
                log.error(
                    "Found nil session when attempting to initialize web view.",
                    context: WebViewControllerError.nilSessionOnBridgeCall
                )
            })
        sessionHandoffSubscription.disposed(by: bag)
    }
    
    private func loadUrl() {
        guard !isLoaded else { return }
        isLoaded = true

        let request = URLRequest(url: webClient.navigationURL)
        log.debug("Starting to load \(webClient.navigationURLDescription)")

        #if DEBUG
        if let html = ProcessInfo.processInfo.environment["webViewMockData"] {
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            webView.load(request)
        }
        #else
        webView.load(request)
        #endif
    }
    
    @objc public func sectionRequiresUpdateNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            if let section = notification.object as? String {
                log.debug("WebViewController: \(self) reacting to section requires update to reload section")
                self.send(message: .sectionRequiresUpdate(section: section))
            }
        }
    }

    @objc func backButtonTapped() {
        let isTabSwitchAllowed = UITabBarControllerComponent.switchingAllowedDictionary["isTabSwitchingAllowed"]
            as? Bool ?? true
        if webView != nil && webView.canGoBack {
            if isTabSwitchAllowed {
                webView.goBack()
                return
            }
            showStopSwitchingAlert(onContinue: {
                self.webView.goBack()
                self.onNavigationAction()
            })
        } else {
            if isTabSwitchAllowed {
                navigationController?.popViewController(animated: true)
                onNavigationAction()
                return
            }
            showStopSwitchingAlert()
        }
    }
    
    /// Run a block on the serial "emit" queue. While the block is running, `emitting` will be true,
    /// and session change subscriptions will be paused to avoid reacting to a value emitted from `self`.
    private func emit(block: @escaping () -> Void) {
        WebViewController.emitQueue.async {
            DispatchQueue.main.async {
                self.emitting = true
                block()
                self.emitting = false
            }
        }
    }

    private func setupProfileIcon() {
        let iconComponent = profileIconCoordinator.profileIconComponent
        iconComponent.customView?.snp.makeConstraints({ maker in
            maker.width.equalTo(32)
            maker.height.equalTo(32)
        })
        navigationItem.rightBarButtonItem = iconComponent
        profileIconCoordinator.setupForViewController(self)
    }

    /// Handles the action of closing a modally presented instance.
    ///
    /// - Parameter sender: The UIBarButtonItem sending the action. In this case,
    ///     it should be the done button (right bar button item) that exists when
    ///     when the web view is presented modally.
    @objc private func doneButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func cogButtonTouched(_ sender: UIBarButtonItem) {
        self.showModalWebView(forComponentPath: WebComponentPath(path: "alert-management"))
    }
    
    func showModalWebView(forComponentPath componentPath: WebComponentPath) {
           guard let webClient = try? webClientFactory.create(componentPath: componentPath) else { return }

            let webViewController = WebViewController(
                l10nProvider: l10nProvider,
                componentStyleProvider: componentStyleProvider,
                webClient: webClient,
                isRootComponent: true,
                externalWebViewControllerFactory: externalWebViewControllerFactory,
                pdfPresenter: pdfPresenter,
                urlOpener: urlOpener,
                messageStatsManager: messageStatsManager,
                webViewExtensionsCache: webViewExtensionsCache,
                analyticsTracker: analyticsTracker,
                inAppRatingManager: inAppRatingManager,
                profileIconCoordinatorFactory: profileIconCoordinatorFactory,
                isModal: true,
                webProcessPool: webProcessPool,
                cardControl: cardControl,
                webClientFactory: webClientFactory,
                qrScannerFactory: qrScannerFactory
            )

        webViewController.navigationTextStyle = "navigationTitleOnDefault"
        webViewController.navigationStyle = "navigationBarOnDefault"
        webViewController.statusBarStyle = "statusBarOnDefault"

        let navigationController = UINavigationControllerComponent(
            rootViewController: webViewController
        )

       present(navigationController, animated: true, completion: nil)
        
    }

}

extension WebViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive scriptMessage: WKScriptMessage) {
        let parameters = scriptMessage.body as? [String: Any]
        let promiseId = parameters?["promiseId"] as? String
        
        // To make the bridge call from the web to application, use:
        //
        // window.webkit.messageHandlers[channel].postMessage(messageObj)
        //
        // where `channel` is the `WebToNativeMessage` that you are trying to send
        // and `messageObj` is the message object that you would like to send in the
        // bridge call.
        //
        // It is important that all promises be resolved as success or an error.
        // Not resolving promises can lead to unexplained "white screens" that are difficult
        // to debug. According to the UI team, if an error occurrs you can reject by calling
        //
        // `d3.resolvePromise(promiseId, data, error)`
        //
        // To reject the promise silently in the web view
        //      "send undefined for data with error defined and it should not show an error
        //      on our side and reject the promise"
        guard let message = WebToNativeMessage(rawValue: scriptMessage.name) else {
            if let id = promiseId {
                resolvePromise(id: id, error: "Received an unexpected script message: \(scriptMessage)")
            }
            
            return
        }

        log.info("Handling message from web: \(message)")
        
        switch message {
        case .closeZelleModal:
            dismiss(animated: true)
            resolvePromise(id: promiseId)

        case .csrf:
            if let csrfToken = webClient.userSession.session?.csrfToken {
                resolvePromise(id: promiseId, withString: csrfToken)
            } else {
                resolvePromise(id: promiseId, error: "CSRF Token not found")
            }

        case .device:
            if let json = webClient.deviceJSON {
                resolvePromise(id: promiseId, withJSON: json)
            } else {
                resolvePromise(id: promiseId, error: "Failed to get device json")
            }

        case .download:
            if let urlString = parameters?["url"] as? String, let url = URL(string: urlString) {
                // We need to make sure that all of the cookies on this web view are added to the shared cookie store
                // before trying to present the pdf as one of these cookies may be required to download the resource.
                self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies({ [weak self] cookies in
                    guard let self = self else { return }
                    
                    let sharedCookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies ?? []
                    
                    cookies.forEach { cookie in
                        if !sharedCookies.contains(cookie) {
                            HTTPCookieStorage.shared.setCookie(cookie)
                        }
                    }
                    self.downloadPDF(url: url)
                })
            } else {
                log.warning("Failed to get URL to download PDF")
            }
            resolvePromise(id: promiseId)

        case .extensions:
            webViewExtensionsCache.getEnabledExtensions(completion: { response in
                self.resolvePromise(id: promiseId, withJSON: response.toJSONString())
            })
            
        case .getLocalization:
            let isBusinessProfile = webClient.userSession.selectedProfile?.profileType == "BUSINESS"
            if isBusinessProfile {
                NotificationCenter.default.post(
                    name: .updatedL10nNotification,
                    object: nil,
                    userInfo: LocalizationDataProvider().BusinessLocalizableData()
                )
                let json = localJsonFileContents(named: "BusinessWebLocalizable")
                resolvePromise(id: promiseId, withJSON: json)
            } else {
                NotificationCenter.default.post(
                    name: .updatedL10nNotification,
                    object: nil,
                    userInfo: LocalizationDataProvider().ConsumerLocalizableData()
                )
                let json = localJsonFileContents(named: "WebLocalizable")
                resolvePromise(id: promiseId, withJSON: json)
            }
           
        case .getSnapshotToken:
            if let token = webClient.userStore.snapshotToken {
                resolvePromise(id: promiseId, withString: token)
            } else {
                resolvePromise(id: promiseId)
            }

        case .getZelleContact:
            // Promise resolved in ContactsHelper.selectedContactProperty subscription.
            contactsHelper.chooseContact(fromViewController: self, withPromiseId: promiseId, mode: .zelle)

        case .getZelleProfileQRCodes:
            guard let profiles = parameters?["profiles"] as? [[String: Any]] else {
                resolvePromise(id: promiseId)
                return
            }
            let qrInfoBuilder = ZelleQRInfoBuilder(userProfileQRTokens: [], l10nProvider: l10nProvider)
            let qrUtils = QRCodeUtils()
            let qrs: [[String: Any]] = profiles.map {
                var item = $0
                let model = ZelleQRDataModel(name: $0["name"] as? String ?? "", token: $0["token"] as? String ?? "")
                item["image"] = qrUtils.generateQRCode(from: qrInfoBuilder.buildInfo(from: model) ?? "")?
                    .pngData()?
                    .base64EncodedString() ?? ""
                return item
            }
            let response = String(data: try! JSONSerialization.data(withJSONObject: qrs, options: .fragmentsAllowed),
                                  encoding: .utf8) ?? ""
            resolvePromise(id: promiseId, withJSON: response)
            
        case .hasFaceId:
            let hasFaceId = webClient.biometricsHelper.supportedBiometricType == .faceId
            resolvePromise(id: promiseId, withJavaScriptExpression: hasFaceId ? "true" : "false")

        case .inAppRatingEvent:
            guard let eventName = parameters?["eventName"] as? String else {
                resolvePromise(id: promiseId)
                return
            }
            
            inAppRatingManager.engage(event: eventName, fromViewController: self)
            
            resolvePromise(id: promiseId)

        case .isFingerprintAllowed:
            let hasBiometrics = webClient.biometricsHelper.supportedBiometricType != .none
            resolvePromise(id: promiseId, withJavaScriptExpression: hasBiometrics ? "true": "false")

        case .log:
            let message = parameters?["message"] ?? "Web view experienced an error"
            log.error(message, context: WebBridgeError.generic)
            resolvePromise(id: promiseId)

        case .logout:
            NotificationCenter.default.post(Notification(name: .loggedOut))
            if let errorMessage = parameters?["errorMessage"] as? String {
                let userDefaults = UserDefaults(suiteName: AppConfiguration.applicationGroup)!
                userDefaults.set(value: errorMessage, key: KeyStore.logOutErrorMessage)
            }
            resolvePromise(id: promiseId)

        case .maintenance:
            var userInfo = [String: Any]()
            if let message = parameters?["message"] as? String {
                userInfo["message"] = message
            }
            NotificationCenter.default.post(name: .maintenance, object: self, userInfo: userInfo)
            resolvePromise(id: promiseId)

        case .openCardControls:
            cardControl.launchCardControls(loadingPresenter: self)

        case .openHtmlDocument:
            if let document = parameters?["html"] as? String {
                showExternalWebViewController(destination: .document(document))
            }
            resolvePromise(id: promiseId)

        case .openURL:
            guard let urlString = parameters?["url"] as? String,
                let url = URL(string: urlString) else {
                    resolvePromise(id: promiseId, error: "No url provided")
                    return
            }

            if url.pathExtension == "pdf" {
                pdfPresenter.presentPDF(atURL: url, fromViewController: self).subscribe({ (error) in
                    log.error("Error presending PDF: \(error)", context: error)
                }).disposed(by: bag)
            } else if let navigation = parameters?["navigation"] as? [String: Any],
                let config = try? ExternalWebViewNavigationConfig(configuration: navigation) {
                showExternalWebViewController(destination: .url(url), navigationConfig: config)
            } else {
                let config = ExternalWebViewNavigationConfig(navigable: true, shareable: true)
                showExternalWebViewController(destination: .url(url), navigationConfig: config)
            }

            resolvePromise(id: promiseId)

        case .openURLExternal:
            guard let urlString = parameters?["url"] as? String,
                let url = URL(string: urlString) else {
                    resolvePromise(id: promiseId, error: "No url provided")
                    return
            }

            if let confirmation = parameters?["confirmation"] as? [String: Any] {
                guard let alert = try? OpenURLExternalConfirmation(confirmation: confirmation) else {
                    resolvePromise(id: promiseId, error: "Couldn't parse confirmation object")
                    return
                }
                openURLExternal(url: url, alert: alert)
            } else {
                urlOpener.open(url: url)
            }

            resolvePromise(id: promiseId)
            
        case .allowTabSwitch:
            if let isTabSwitchingAllowed = parameters?["isTabSwitchingAllowed"] as? Bool {
                UITabBarControllerComponent.switchingAllowedDictionary["isTabSwitchingAllowed"] = isTabSwitchingAllowed
                if !isTabSwitchingAllowed {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(stopSwitchingTabNotification(notification:)),
                        name: .stopTabSwitchNotification,
                        object: nil
                    )
                }
            }
            
            if let confirmation = parameters?["confirmation"] as? [String: Any] {
                guard let alertInformation = try? SwitchTabAlertConfirmation(confirmation: confirmation) else {
                    resolvePromise(id: promiseId, error: "Couldn't parse confirmation object")
                    return
                }
                UITabBarControllerComponent.switchingAllowedDictionary["confirmation"] = alertInformation
            }
            resolvePromise(id: promiseId)

        case .openZelleModal:
            let path = parameters?["href"] as? String ?? ""

            openZelleModalWebView(forComponentPath: WebComponentPath(path: path))
            resolvePromise(id: promiseId)

        case .openZelleScanQRCodeModal:
            showQRScanner(mode: .scan, profilesData: parameters?["profiles"] as? [[String: Any]] ?? [], promiseId: promiseId)
            
        case .openZelleViewQRCodeModal:
            showQRScanner(mode: .view, profilesData: parameters?["profiles"] as? [[String: Any]] ?? [], promiseId: promiseId)
            resolvePromise(id: promiseId)
        
        case .sectionRequiresUpdate:
            if let section = parameters?["section"] as? String {
                NotificationCenter.default.post(name: .sectionRequiresUpdateNotification, object: section)
            }
            resolvePromise(id: promiseId)
            
        case .selectProfile:
            if let index = parameters?["index"] as? Int {
                emit {
                    self.webClient.userSession.selectProfile(index: index)
                }
            }
            resolvePromise(id: promiseId)
            
        case .session:
            bridgeCallTimeoutSubscription.dispose()

            if let sessionJSON = webClient.sessionJSON {
                sessionHandoffSubscription.dispose()
                resolvePromise(id: promiseId, withJSON: sessionJSON)
            } else {
                resolvePromise(id: promiseId, error: "Failed to get the session")
            }

        case .startup:
            if let json = webClient.startupJSON {
                resolvePromise(id: promiseId, withJSON: json)
            } else {
                resolvePromise(id: promiseId, error: "Failed to get startup data")
            }
            
        case .storeSnapshotToken:
            let token = parameters?["token"] as? String
            webClient.userStore.setSnapshotToken(token)
            NotificationCenter.default.post(name: .snapshotTokenUpdatedNotification, object: nil)
            resolvePromise(id: promiseId)
            
        case .theme:
            let json = localJsonFileContents(named: "theme")
            resolvePromise(id: promiseId, withJSON: json)

        case .toggleFingerprint:
            toggleFingerprint(enable: parameters?["enable"] as? Bool).subscribe { [unowned self] (event) in
                if case .error(let error) = event {
                    log.error("Error toggling fingerprint: \(error)", context: error)
                    
                    if case let ResponseError.failureWithMessage(message) = error {
                        self.showErrorAlert(message: message)
                    } else {
                        self.showErrorAlert()
                    }
                    
                    self.resolvePromise(id: promiseId, error: "error")
                } else {
                    self.resolvePromise(id: promiseId)
                }
            }.disposed(by: bag)

        case .updateBadge:
            messageStatsManager.webUpdateTrigger.accept(())
            resolvePromise(id: promiseId)

        case .updateUserProfile:
            if
                let index = parameters?["index"] as? Int,
                let userProfileDictionary = parameters?["userProfile"] as? [String: Any] {
                emit {
                    self.webClient.updateUserProfile(fromDictionary: userProfileDictionary, at: index)
                }
            }
            resolvePromise(id: promiseId)
            
        case .url:
            resolvePromise(id: promiseId, withString: webClient.domain.absoluteString)
            
        case .getDeviceContacts:
            contactsHelper.getDeviceContacts(contactsCompletionHandler: { (permission, deviceContacts) in
                switch (permission) {
                case .granted, .notDetermined:
                    do {
                        let jsonData: Data = try JSONEncoder().encode(deviceContacts)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            self.resolvePromise(id: promiseId, withJSON: jsonString)
                        }
                    } catch let error as NSError {
                        fatalError("Device Contacts Array convertIntoJSON - \(error.description)")
                    }
                    
                case .denied:
                     self.resolvePromise(id: promiseId, error: "Permission denied by the User to read contacts from device")
                }
            })
        case .hasPromptedForContacts:
            let status = contactsHelper.contactsAuthorizationStatus()
            self.resolvePromise(id: promiseId, withString: status)
        }
    }
    
    private func showStopSwitchingAlert(onContinue: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let alertConfirmation = UITabBarControllerComponent.switchingAllowedDictionary["confirmation"]
                as? SwitchTabAlertConfirmation {
                self.showAlertWithContinueAndCancel(alertConfirmation: alertConfirmation,
                                                    onContinue: onContinue)
            }
        }
    }
    
    @objc private func stopSwitchingTabNotification(notification: NSNotification) {
        showStopSwitchingAlert()
    }
    
    private func alertValidTitle(alertTitle: String?) -> String {
        if let validTitleValue = alertTitle, !validTitleValue.isEmpty {
            return validTitleValue
        }
        return l10nProvider.localize("dashboard.widget.tab.switching.dialog.default.title")
    }
    
    private func alertValidMessage(alertMessage: String?) -> String {
        if let validMessageValue = alertMessage, !validMessageValue.isEmpty {
            return validMessageValue
        }
        return l10nProvider.localize("dashboard.widget.tab.switching.dialog.default.message")
    }
    
    private func alertValidCancelTitle(alertCancelTitle: String?) -> String {
        if let validCancelTitle = alertCancelTitle, !validCancelTitle.isEmpty {
            return validCancelTitle
        }
        return l10nProvider.localize("dashboard.widget.tab.switching.dialog.default.cancelButton")
    }
    
    private func alertValidContinueTitle(alertContinueTitle: String?) -> String {
        if let validContinueTitle = alertContinueTitle, !validContinueTitle.isEmpty {
            return validContinueTitle
        }
        return l10nProvider.localize("dashboard.widget.tab.switching.dialog.default.confirmButton")
    }
    
    private func showAlertWithContinueAndCancel(alertConfirmation: SwitchTabAlertConfirmation,
                                                onContinue: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(
            title: alertValidTitle(alertTitle: alertConfirmation.title),
            message: alertValidMessage(alertMessage: alertConfirmation.message),
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: alertValidCancelTitle(alertCancelTitle: alertConfirmation.cancelTitle),
            style: .cancel,
            handler: nil
        )
        let onContinue = onContinue ?? { self.stopPaymentProcessAndSwitchTab() }
        let continueAction = UIAlertAction(
            title: alertValidContinueTitle(alertContinueTitle: alertConfirmation.confirmTitle),
            style: .default,
            handler: { _ in
                onContinue()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func stopPaymentProcessAndSwitchTab() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            if let selectedTabIndex = UITabBarControllerComponent.switchingAllowedDictionary["selectedIndex"] as? Int {
                self.tabBarController?.selectedIndex = selectedTabIndex
            }
            self.onNavigationAction()
        }
    }
    
    private func downloadPDF(url: URL) {
        self.pdfPresenter
            .presentPDF(atURL: url, fromViewController: self)
            .subscribe({ (result) in
                switch result {
                case .completed:
                    log.info("PDF successfully presented")
                case .error(let error):
                    log.error("Error presending PDF: \(error)", context: error)
                    let errorViewController = NoItemsViewController(
                        componentStyleProvider: self.componentStyleProvider,
                        text: self.l10nProvider.localize("device.pdf.error"),
                        action: {
                            if let topViewController = self.navigationController?.topViewController,
                               topViewController.isKind(of: NoItemsViewController.self) {
                                self.navigationController?.popViewController(animated: true)
                            }
                            self.downloadPDF(url: url)
                        }
                    )
                    errorViewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(errorViewController, animated: true)
                }
            })
            .disposed(by: self.bag)
    }

    private func showErrorAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(
            title: title ?? l10nProvider.localize("app.error.generic.title"),
            message: message ?? l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: nil)
        )
        
        present(alert, animated: true, completion: nil)
    }

    private func presentPDF(atURL url: URL, fromViewController presentingViewController: UIViewController) {
        pdfPresenter
            .presentPDF(atURL: url, fromViewController: presentingViewController)
            .subscribe(onError: { (error) in
                log.error("Error presenting PDF: \(error)", context: error)
            })
            .disposed(by: bag)
    }
    
    private func showExternalWebViewController(destination: ExternalWebViewController.WebDestination,
                                               navigationConfig: ExternalWebViewNavigationConfig = .init(navigable: true)) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let viewController = self.externalWebViewControllerFactory.create(
                destination: destination,
                navigationConfig: navigationConfig,
                cookies: cookies,
                delegate: self
            )

            self.present(viewController, animated: true)
        }
    }

    private func openURLExternal(url: URL, alert: OpenURLExternalConfirmation) {
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.confirmTitle, style: .default, handler: { (_) in
            self.urlOpener.open(url: url)
        }))

        present(alertController, animated: true, completion: nil)
    }   
        
    private func toggleFingerprint(enable: Bool?) -> Completable {
        guard let enable = enable else {
            return Completable.error(WebError.invalidOrMissingScriptParameter(name: "enable"))
        }
        
        if enable {
            return webClient.biometricsHelper.optInBiometricAuth()
        } else {
            return webClient.biometricsHelper.optOutBiometricAuth()
        }
    }

    /// Resolves a promise with `undefined`
    private func resolvePromise(id promiseId: String?, error: String? = nil) {
        resolvePromise(id: promiseId, withJavaScriptExpression: "undefined", error: error)
    }
    
    private func resolvePromise(id promiseId: String?, withString string: String, error: String? = nil) {
        resolvePromise(id: promiseId, withJavaScriptExpression: "'\(string)'", error: error)
    }
    
    private func resolvePromise(id promiseId: String?, withJSON json: String, error: String? = nil) {
        resolvePromise(id: promiseId, withJavaScriptExpression: "JSON.stringify(\(json))", error: error)
    }
    
    private func resolvePromise(id promiseId: String?, withJavaScriptExpression expression: String, error: String? = nil) {
        guard let promiseId = promiseId else {
            log.warning("No promise ID in script message")
            return
        }

        // The actual form that the web expects is `resolvePromise(promiseId: string, data: any, error: string)`.
        // We will generally always call with the promiseId and data however, if there is an error we will want
        // to send that along too.
        var javascript = "d3.resolvePromise('\(promiseId)',\(expression)"
        if let error = error {
            log.error(error)
            javascript += ",'\(error)')"
        } else {
            javascript += ")"
        }
        
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(javascript)
        }
    }
    
    private func localJsonFileContents(named name: String) -> String {
        if
            let url = WebBundle.bundle.url(forResource: name, withExtension: "json"),
            let data = try? Data(contentsOf: url, options: .mappedIfSafe),
            let string = try? String(jsonData: data)
        {
            log.debug("Loaded \(name).json")
            return string
        }

        log.warning("Unable to read \(name).json")
        return "{}"
    }

    private func send(message: NativeToWebMessage) {
        do {
            let json = try message.encodedJson()
            let javascript = "d3.sendMessage(\(json))"
            if let webView = self.webView {
                webView.evaluateJavaScript(javascript)
            }
        } catch {
            log.error("Error sending message from native to web: \(error)", context: error)
        }
    }

    /// Presents an instance of the web view modally.
    ///
    /// - Parameter url: The url to be loaded by the presented web view.
    private func openZelleModalWebView(forComponentPath componentPath: WebComponentPath) {
        let externalWebClient = WebClient(
            domain: webClient.domain,
            client: webClient.client,
            device: webClient.device,
            componentPath: componentPath,
            userSession: webClient.userSession,
            biometricsHelper: webClient.biometricsHelper,
            userStore: webClient.userStore,
            startupHolder: webClient.startupHolder
        )

        let webViewController = WebViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            webClient: externalWebClient,
            isRootComponent: true,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            pdfPresenter: pdfPresenter,
            urlOpener: urlOpener,
            messageStatsManager: messageStatsManager,
            webViewExtensionsCache: webViewExtensionsCache,
            analyticsTracker: analyticsTracker,
            inAppRatingManager: inAppRatingManager,
            profileIconCoordinatorFactory: profileIconCoordinatorFactory,
            isModal: true,
            webProcessPool: webProcessPool,
            cardControl: cardControl,
            webClientFactory: webClientFactory,
            qrScannerFactory: qrScannerFactory
        )

        present(webViewController, animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            log.debug("Allowing the request")
            decisionHandler(.allow)
            return
        }
 
        urlOpener.handle(url: url) ? decisionHandler(.cancel) : decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        log.debug("commited navigation/started loading stuff")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        log.debug("finished loading....")
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        log.error("Web view loading failed...", context: error)
    }
}

extension WebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: { (_) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true)
    }

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            showExternalWebViewController(destination: .url(url))
        }

        return nil
    }
}

extension WebViewController: InternalNavigationViewController {
    public func popToNavigationRoot() {
        if let rootItem = webView.backForwardList.backList.first {
            webView.go(to: rootItem)
        }
    }
}

extension WebViewController: ExternalWebViewControllerDelegate {
    public func externalWebViewController(_ viewController: ExternalWebViewController, navigatingToPDFAtURL url: URL) {
        self.presentPDF(atURL: url, fromViewController: viewController)
    }

    public func externalWebViewController(_: ExternalWebViewController, didReceiveData data: [String: String]) {}
}

private extension WebViewController {
    func onNavigationAction() {
        UITabBarControllerComponent.switchingAllowedDictionary["isTabSwitchingAllowed"] = true
        UITabBarControllerComponent.switchingAllowedDictionary["selectedIndex"] = nil
    }
}

private extension WebViewController {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onfeatureTourFinished), name: .featureTourFinished, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .featureTourFinished, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func onfeatureTourFinished() {
        send(message: .featureTourCompleted)
    }
    
    @objc func keyboardWillShown(_ notificiation: NSNotification) {
        guard let keyboardContainer = UIApplication.shared.windows.last else {
            return
        }
        if let picker: UIPickerView = keyboardContainer.firstSubviewOfKind() {
            if picker.delegate as? WebViewController == nil {
                originalPickerDelgate = picker.delegate
                picker.delegate = self
                pickerRowHeight = 0
            }
        }
    }
}

extension WebViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView,
                           viewForRow row: Int,
                           forComponent component: Int,
                           reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width - 32, height: 40))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.attributedText = originalPickerDelgate?.pickerView?(pickerView, attributedTitleForRow: row, forComponent: component)
        label.sizeToFit()
        pickerRowHeight = max(pickerRowHeight, label.frame.height)
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerRowHeight
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        originalPickerDelgate?.pickerView?(pickerView, didSelectRow: row, inComponent: component)
    }
}

// MARK: QR Scanner
private extension WebViewController {
    func showQRScanner(mode: QRScannerViewControllerMode, profilesData: [[String: Any]], promiseId: String?) {
        qrScannerPresenter.showQRScanner(mode: mode, profilesData: profilesData, on: self, onQRScanned: { [weak self] qr in
            self?.resolvePromise(id: promiseId, withString: qr)
        }, onQRScanError: { [weak self] _ in
            self?.resolvePromise(id: promiseId)
        })
    }
}
