//
//  ExternalWebViewController.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/31/18.
//

import UIKit
import WebKit
import RxSwift
import RxRelay
import SnapKit
import Utilities
import Logging
import D3Contacts
import FIS

public final class ExternalWebViewController: UIViewControllerComponent {
    public enum WebDestination {
        case url(URL)
        case document(String)
    }
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private lazy var doneButton = { () -> UIBarButtonItem in
        let barbuttonItem = UIBarButtonItem(
            image: UIImage(named: "CloseButton"),
            style: .plain,
            target: self,
            action: #selector(self.doneButtonTapped)
        )
        barbuttonItem.accessibilityValue = "Close"
        barbuttonItem.accessibilityIdentifier = "CloseButton"
        return barbuttonItem
    }
        
    private lazy var backButton = UIBarButtonItem(
        image: UIImage(named: "LeftArrow"),
        style: .plain,
        target: self,
        action: #selector(backButtonTapped)
    )
    private lazy var refreshButton = { () -> UIButton in
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "Refresh"), for: .normal)
        button.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        button.snp.makeConstraints { (make) in
            make.width.equalTo(44).priority(999)
            make.height.equalTo(44).priority(999)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        return button
    }()
    private lazy var forwardButton = UIBarButtonItem(
        image: UIImage(named: "RightArrow"),
        style: .plain,
        target: self,
        action: #selector(forwardButtonTapped)
    )
    private lazy var shareButton = UIBarButtonItem(
        barButtonSystemItem: .action,
        target: self,
        action: #selector(shareButtonTapped)
    )
    
    private let destination: WebDestination
    private let device: Device
    private let isNavigable: Bool
    private let isRefreshable: Bool
    private let isShareable: Bool
    private let urlOpener: URLOpener
    private let cookies: [HTTPCookie]
    private let contactsHelper: ContactsHelper
    
    weak var delegate: ExternalWebViewControllerDelegate?
    
    public init(config: ComponentConfig,
                destination: WebDestination,
                device: Device,
                navigationConfig: ExternalWebViewNavigationConfig,
                urlOpener: URLOpener,
                cookies: [HTTPCookie] = []) {
        self.destination = destination
        self.device = device
        self.isNavigable = navigationConfig.navigable
        self.isRefreshable = navigationConfig.refreshable
        self.isShareable = navigationConfig.shareable
        self.urlOpener = urlOpener
        self.cookies = cookies
        self.contactsHelper = ContactsHelper()
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: ComponentKitBundle.bundle
        )

        contactsHelper
            .selectedContactProperty
            .subscribe(onNext: { [unowned self] result in
                if let json = result.json {
                    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    switch result.mode {
                    case .fiserv:
                        self.webView.evaluateJavaScript("handleSelectedContact(`\(jsonString)`)")
                    case .zelle:
                        // Not supported for ExternalWebViewController
                        break
                    }
                }
            })
            .disposed(by: bag)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // This is very strange, but we must create a new
        // WKWebsiteDataStore, and set the cookies on that store.
        // After creating the WKWebsiteDataStore, we then have to
        // create a new WKWebViewConfiguration and set its websiteDataStore
        // to the new one we just created. Once this is done, we must create
        // a new WKWebView with the new configuration. The setting of the cookies
        // is asynchronous so the creation of the web view and loading must be done
        // in the completion of setting the cookies to make sure that they are present.
        let websiteDataStore = WKWebsiteDataStore.nonPersistent()
        websiteDataStore.httpCookieStore.set(cookies: cookies) {
            let config = WKWebViewConfiguration()
            config.websiteDataStore = websiteDataStore
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

            let newWebView = WKWebView(frame: self.webView.frame, configuration: config)
            self.webView = newWebView
            self.view.addSubview(self.webView)
            self.webView.snp.makeConstraints { make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.bringSubviewToFront(self.progressView)

            self.configureWebView()
            self.setupNavigationBar()
            
            self.loadDestination(destination: self.destination)
        }
    }
    
    private func loadDestination(destination: WebDestination) {
        switch destination {
        case .url(let url):
            #if DEBUG
            if let html = ProcessInfo.processInfo.environment["externalWebViewMockData"] {
                webView.loadHTMLString(html, baseURL: nil)
            } else {
                webView.load(URLRequest(url: url))
            }
            #else
            webView.load(URLRequest(url: url))
            #endif
        case .document(let document):
            webView.loadHTMLString(document, baseURL: nil)
        }
    }

    func configureWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self

        #if DEBUG
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        
        webView
            .rx
            .estimatedProgress
            .subscribe(onNext: { [unowned self] (estimatedProgress) in
                self.progressView.setProgress(Float(estimatedProgress), animated: true)
            })
            .disposed(by: bag)
        
        webView
            .rx
            .isLoading
            .subscribe(onNext: { [unowned self] (isLoading) in
                if !isLoading {
                    self.progressView.setProgress(0, animated: false)
                }
                self.refreshButton.isEnabled = !isLoading
                self.progressView.isHidden = !isLoading
            })
            .disposed(by: bag)
        
        FISConnector().connect(to: webView)
    }

    private func setupNavigationBar() {
        navigationItem.leftItemsSupplementBackButton = isNavigable

        var leftBarButtonItems = [UIBarButtonItem]()
        leftBarButtonItems.append(doneButton())

        if isNavigable {
            leftBarButtonItems.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
                backButton
            ])
        }

        var rightBarButtonItems = [UIBarButtonItem]()

        if isShareable {
            rightBarButtonItems.append(shareButton)
        }

        if isNavigable {
            rightBarButtonItems.append(contentsOf: [
                forwardButton,
                UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            ])
        }

        navigationItem.leftBarButtonItems = leftBarButtonItems
        navigationItem.titleView = isRefreshable ? refreshButton : nil
        navigationItem.rightBarButtonItems = rightBarButtonItems

        backButton.isEnabled = false
        refreshButton.isEnabled = false
        forwardButton.isEnabled = false

        webView
            .rx
            .canGoBack
            .subscribe(onNext: { [unowned self] (canGoBack) in
                self.backButton.isEnabled = canGoBack
            })
            .disposed(by: bag)

        webView
            .rx
            .canGoForward
            .subscribe(onNext: { [unowned self] (canGoForward) in
                self.forwardButton.isEnabled = canGoForward
            })
            .disposed(by: bag)
    }
    
    @objc func doneButtonTapped() {
        close()
    }
    
    @objc func shareButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.print"), style: .default, handler: { (_) in
            self.print()
        }))
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.cancel"), style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = shareButton
        }
        
        present(alertController, animated: true)
    }

    @objc func backButtonTapped() {
        webView.goBack()
    }
    
    @objc func refreshButtonTapped() {
        webView.reload()
    }
    
    @objc func forwardButtonTapped() {
        webView.goForward()
    }
    
    func close() {
        dismiss(animated: true)
    }
    
    func print() {
        webView.htmlContent().subscribe { [unowned self] (event) in
            switch event {
            case .success(let html):
                self.print(html: html)
            case .error(let error):
                log.error("Error getting HTML content for printing: \(error)", context: error)
            }
        }.disposed(by: bag)
    }
    
    private func print(html: String) {
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
        let printController = UIPrintInteractionController.shared
        printController.printFormatter = formatter

        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        printerPicker.present(animated: true) { (printerPicker, userDidSelect, error) in
            if let error = error {
                log.error("Error picking printer: \(error)", context: error)

                return
            }
            if userDidSelect {
                printController.print(to: printerPicker.selectedPrinter!, completionHandler: nil)
            }
        }
    }
}

extension ExternalWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        var data: [String: String] = [:]
        
        if let url = webView.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { queryItem in
                guard let value = queryItem.value else { return }
                
                data[queryItem.name] = value
            }
        }
        
        if webView.url?.pathComponents.contains("d3:returnToNativeLogin") == true {
            close()
            NotificationCenter.default.post(name: .returnToNativeLogin, object: nil)
        }
        
        if !data.isEmpty {
            delegate?.externalWebViewController(self, didReceiveData: data)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.isMobile = true") { (_, error) in
            if let error = error {
                log.error("Error setting window.isMobile: \(error)", context: error)
            }
        }
        
        webView.evaluateJavaScript("window.d3DeviceUUID = '\(device.uuid)'") { (_, error) in
            if let error = error {
                log.error("Error setting window.d3DeviceUUID: \(error)", context: error)
            }
        }
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if url.isFiservScheme() {
            performFiservActions(for: url)
            decisionHandler(.cancel)
            return
        }
        
        urlOpener.handle(url: url) ? decisionHandler(.cancel) : decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard
            let mimeType = navigationResponse.response.mimeType,
            let url = navigationResponse.response.url
        else {
            decisionHandler(.allow)
            return
        }

        if mimeType == "application/pdf" {
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies({ [weak self] cookies in
                guard let self = self else { return }

                let sharedCookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies ?? []

                // We need to make sure that any cookies on this web view that are not already in the shared cookie
                // store get put there so that they are there when the native request to download the pdf is made.
                cookies.forEach { cookie in
                    if !sharedCookies.contains(cookie) {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }

                self.delegate?.externalWebViewController(self, navigatingToPDFAtURL: url)
                decisionHandler(.cancel)
            })
        } else {
            decisionHandler(.allow)
        }
    }
}

extension ExternalWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: { (_) in
            completionHandler()
        }))
        
        present(alertController, animated: true)
    }
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.cancel"), style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        
        present(alertController, animated: true)
    }
    
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            self.webView.load(navigationAction.request)
        }

        return nil
    }
}

extension WKWebView {
    func htmlContent() -> Single<String> {
        return Single.create { (observer) -> Disposable in
            self.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
                if let error = error {
                    observer(.error(error))
                } else if let html = result as? String {
                    observer(.success(html))
                } else {
                    observer(.error(WebViewError.script))
                }
            }
            return Disposables.create()
        }
    }
}

enum WebViewError: Error, CustomStringConvertible {
    case script
    
    var description: String {
        switch self {
        case .script:
            return "Error during script evaluation"
        }
    }
}

public protocol ExternalWebViewControllerDelegate: class {
    func externalWebViewController(_: ExternalWebViewController, navigatingToPDFAtURL: URL)
    func externalWebViewController(_: ExternalWebViewController, didReceiveData data: [String: String])
}

extension ExternalWebViewController {
    /// Performs actions based on the Fiserv scheme name (TFK)
    ///
    /// - Parameter url: URL object to evaluate
    private func performFiservActions(for url: URL) {
        let ftkImportContactPrefix = "FTKiOSInterface://FTKImportContact".lowercased()
        if url.absoluteString.lowercased().hasPrefix(ftkImportContactPrefix) {
            contactsHelper.chooseContact(fromViewController: self, withPromiseId: nil, mode: .fiserv)
        }
        let ftkTimeOutPrefix = "FTKiOSInterface://FTKTimeOut".lowercased()
        if url.absoluteString.lowercased().hasPrefix(ftkTimeOutPrefix) {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension URL {
    /// Determines if an URL conforms a Fiserv scheme name (TFK)
    internal func isFiservScheme() -> Bool {
        let ftkPrefix = "FTKiOSInterface".lowercased()
        return self.absoluteString.lowercased().hasPrefix(ftkPrefix)
    }
}
