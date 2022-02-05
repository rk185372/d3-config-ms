//
//  AuthPrimaryViewController.swift
//  AuthFlow
//
//  Created by Chris Carranza on 6/11/18.
//

import AppConfiguration
import CompanyAttributes
import UIKit
import Localization
import Logging
import ComponentKit
import Dashboard
import Navigation
import RxSwift
import RxRelay
import Utilities
import DeviceInfoService
import Biometrics
import Network
import UserInteraction
import ViewPresentable
import ShimmeringData
import Analytics
import ReCaptcha
import InAppRatingApi
import LocalizationData

public final class AuthPrimaryViewController: UIViewControllerComponent, AuthViewController {
    @IBOutlet weak var tabSegmentView: UIView!
    @IBOutlet weak var challengeContainerStackView: UIStackView!
    @IBOutlet weak var challengeItemsStackView: UIStackView!
    @IBOutlet weak var challengeActionsStackView: UIStackView!
    @IBOutlet weak var launchPageItemStackView: UIStackView!
    @IBOutlet weak var launchPageItemContainerView: UIView!
    @IBOutlet weak var snapshotButton: UIButtonComponent!
    @IBOutlet weak var selfEnrollmentButton: UIButtonComponent!
    @IBOutlet weak var copyrightLabel: UILabelComponent!
    @IBOutlet weak var copyrightSecondLineLabel: UILabelComponent!
    @IBOutlet weak var versionLabel: UILabelComponent!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var equalHousingLenderImageView: UIImageViewComponent!
    @IBOutlet weak var memberFDICImageView: UIImageViewComponent!

    private let componentConfig: ComponentConfig
    private let componentFactory: ComponentFactory
    private let challengeService: ChallengeService
    private let mfaEnrollmentService: MFAEnrollmentService
    private let companyAttributes: CompanyAttributesHolder
    private let bundle: Bundle
    private var challengeItemPresenters: [AnyViewPresentable] = []
    private var biometricPresenter: BiometricsPresenter?
    private var biometricsEnrollmentPresenter: BiometricsEnrollmentPresenter?
    private var challengeActionPresenters: [ChallengeActionPresenter] = []
    private var linkButtonPresenters: [ChallengeLinkButtonItemsPresenter] = []
    private var tabSegmentPresenter: [ChallengeTabSegmentPresenter] = []
    private var currentTabIndex: Int
    private var isBusinessProductEnabled: Bool
    
    private var challengePersonalItemPresenters: [AnyViewPresentable] = []
    private var challengeBusinessItemPresenters: [AnyViewPresentable] = []

    private var challenge: ChallengeResponse?
    private var mfaEnrollResponse: MFAEnrollmentResponse?
    private let viewModel: AuthPrimaryViewModel
    private var presenterFactory: ChallengePresenterFactory?
    fileprivate let presenter: AuthPresenter
    private var launchPageItems: [LaunchPageItem] = []
    private let persistenceHelper: ChallengePersistenceHelper
    private var moreItems: [LaunchPageItem] = []
    private let dividerWidth: CGFloat = 1
    private let userInteraction: UserInteraction
    private let analyticsTracker: AnalyticsTracker
    private let restServer: RestServer
    private let uuid: D3UUID
    private let inAppRatingManager: InAppRatingManager

    private let biometricsHelper: BiometricsHelper
    private let biometricsAutoPromptManager: BiometricsAutoPromptManager

    private var reCaptchaHelper: ReCaptchaHelper?
    private var reCaptchaRequired: Bool = false
    private var pickerItemsArray: [String] = []
    private var usernamesPickerView: UIPickerView?
    private var usernamesPickerContainer: UIStackView!
    private var activeProfileIndex: Int = 0

    private enum ActiveState {
        case goingToInactive
        case returningFromInactive
        case active
    }

    private var activeState: ActiveState = .active

    private var challengeItems: [ChallengeItem] = []
    private let challengeHelper = ChallengeHelper()

    private lazy var moreButton = { () -> UIButton in
        let button = self.componentFactory.createButton(style: .buttonNoOutlineOnLogin, l10nKey: "launchPage.menu.more.label")
        button.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    public weak var delegate: AuthDelegate?

    private let userDefaults = UserDefaults(suiteName: AppConfiguration.applicationGroup)!

    init(componentConfig: ComponentConfig,
         viewModel: AuthPrimaryViewModel,
         presenter: AuthPresenter,
         challengeService: ChallengeService,
         mfaEnrollmentService: MFAEnrollmentService,
         persistenceHelper: ChallengePersistenceHelper,
         biometricsHelper: BiometricsHelper,
         biometricsAutoPromptManager: BiometricsAutoPromptManager,
         companyAttributes: CompanyAttributesHolder,
         bundle: Bundle,
         userInteraction: UserInteraction,
         analyticsTracker: AnalyticsTracker,
         restServer: RestServer,
         uuid: D3UUID,
         inAppRatingManager: InAppRatingManager) {
        self.componentConfig = componentConfig
        self.componentFactory = ComponentFactory(config: componentConfig)
        self.viewModel = viewModel
        self.presenter = presenter
        self.challengeService = challengeService
        self.persistenceHelper = persistenceHelper
        self.biometricsHelper = biometricsHelper
        self.biometricsAutoPromptManager = biometricsAutoPromptManager
        self.companyAttributes = companyAttributes
        self.bundle = bundle
        self.userInteraction = userInteraction
        self.analyticsTracker = analyticsTracker
        self.restServer = restServer
        self.uuid = uuid
        self.inAppRatingManager = inAppRatingManager
        self.currentTabIndex = self.persistenceHelper.loadCurrentTabIndex()
        self.isBusinessProductEnabled = self.companyAttributes
            .companyAttributes.value?.boolValue(forKey: "businessAuthentication.businessTab.enabled") ?? false
        self.mfaEnrollmentService = mfaEnrollmentService
        
        super.init(
            l10nProvider: componentConfig.l10nProvider,
            componentStyleProvider: componentConfig.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AuthenticationBundle.bundle
        )

        self.challengeService.delegate = self
        setupReCaptchaHelper()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        presenter.delegate = self

        backgroundImageView.image = UIImage(named: "Background")
        logoImageView.image = UIImage(named: "FullLogo")
        logoImageView.accessibilityLabel = l10nProvider.localize("login.d3logo.altText")
        memberFDICImageView.accessibilityLabel = l10nProvider.localize("launchPage.fdic.altText")
        equalHousingLenderImageView.accessibilityLabel = l10nProvider.localize("launchPage.equalHousingLender.altText")
        
        self.getUpdateLaunchPageItemsForTabIndex()

        setupBiometrics()
        refreshChallenge()

        biometricsAutoPromptManager
            .autoPrompt
            .drive(onNext: { [unowned self] _ in
                let analyticsName = (self.biometricsHelper.supportedBiometricType == .faceId)
                    ? "LoginWithFaceID"
                    : "LoginWithTouchID"
                self.analyticsTracker.trackEvent(AnalyticsEvent(category: "AUTHENTICATION", action: .autoPrompt, name: analyticsName))

                if self.persistenceHelper.enableBiometrics {
                    self.authenticateWithBiometrics()
                }
            })
            .disposed(by: bag)

        NotificationCenter
            .default
            .rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: { [unowned self] _ in
                self.activeState = .returningFromInactive
                self.biometricsAutoPromptManager.willEnterForegroud()
            })
            .disposed(by: bag)

        NotificationCenter
            .default
            .rx
            .notification(UIApplication.willResignActiveNotification)
            .subscribe(onNext: { [unowned self] _ in
                self.activeState = .goingToInactive
            })
            .disposed(by: bag)

        NotificationCenter
            .default
            .rx
            .notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { [unowned self] _ in
                self.activeState = .active
            })
            .disposed(by: bag)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayMaxSavedUserAlert(notification:)),
            name: .displayMaxSavedUserAlert,
            object: nil
        )

        NotificationCenter
            .default
            .rx
            .notification(.returnToNativeLogin)
            .subscribe(onNext: { [unowned self] _ in
                self.navigationController?.popToViewController(self, animated: false)
                self.setTextChallengeValue(nil, forChallenge: .password)
        })
        .disposed(by: bag)
        
        updateLaunchPageButtons()
        updateLaunchPageFooter()

        evaluateLogOutErrorMessage()
        getPickerItemsArray()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchOutSideThePicker(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inAppRatingManager.engage(event: "login:displayed", fromViewController: self)
        biometricsAutoPromptManager.primaryViewVisible(true)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        biometricsAutoPromptManager.primaryViewVisible(false)
        biometricPresenter?.stopSpinner()
        self.cancelables.cancel()
    }

    private func getPickerItemsArray() {
        var items: [String] = []
        let users = persistenceHelper.savedUsernames(currentTabIndex: currentTabIndex).map{ $0.masked() }
        items.append(contentsOf: users)
        let newUsername = currentTabIndex == 0 ?
            l10nProvider.localize("login.signinnewusername.text") : l10nProvider.localize("login.signinnewbusinessuser.text")
        items.append(newUsername)
        items.append(l10nProvider.localize("login.editusername.text"))
        pickerItemsArray = items
    }
    
    @objc private func touchOutSideThePicker(_ sender: UITapGestureRecognizer) {
        removePickerView()
    }
    
    @objc private func displayMaxSavedUserAlert(notification: NSNotification) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: self.l10nProvider.localize("login.maxalerttitle.text"),
                message: self.l10nProvider.localize("login.maxalertmessage.text"),
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: self.l10nProvider.localize("login.cancelalert.text"),
                style: .cancel,
                handler: nil
            )
            let saveAction = UIAlertAction(
                title: self.l10nProvider.localize("login.edituser.text"),
                style: .default,
                handler: { _ in
                    self.openDeleteUserNamesView()
                })
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setupReCaptchaHelper() {
        self.reCaptchaHelper = nil

        guard let attributes: CompanyAttributes = companyAttributes.companyAttributes.value else { return }
        guard let baseURL: URL = try? restServer.url.host?.asURL() else { return }
        guard let apiKey: String = attributes.value(forKey: "consumerAuthentication.recaptcha.siteApiKey.ios") else { return }

        self.reCaptchaHelper = ReCaptchaHelper(
            apiKey: apiKey,
            baseURL: baseURL,
            delegate: self
        )
    }

    private func setupBiometrics() {
        biometricsEnrollmentPresenter = BiometricsEnrollmentPresenter(
            supportedBiometricType: biometricsHelper.supportedBiometricType,
            l10nProvider: l10nProvider,
            delegate: self
        )
        let enrollmentView = biometricsEnrollmentPresenter!.createView()
        challengeContainerStackView.insertArrangedSubview(enrollmentView, at: 1)
        biometricsEnrollmentPresenter?.configure(view: enrollmentView)
        enrollmentView.isHidden = !biometricsHelper.biometricAuthNeedsEnabled

        biometricPresenter = BiometricsPresenter(
            supportedBiometricType: biometricsHelper.supportedBiometricType,
            l10nProvider: l10nProvider,
            delegate: self
        )
        let biometricView = biometricPresenter!.createView()
        challengeContainerStackView.insertArrangedSubview(biometricView, at: 3)
        biometricPresenter?.configure(view: biometricView)
        biometricView.isHidden = !biometricsHelper.biometricAuthEnabled
    }

    private func refreshBiometrics() {
        refreshEnrollmentView()
        refreshBiometricsView()
    }

    private func refreshEnrollmentView() {
        challengeContainerStackView.arrangedSubviews
            .first(where: { $0 is BiometricsEnrollmentView })?.isHidden = !biometricsHelper.biometricAuthNeedsEnabled
    }

    private func refreshBiometricsView() {
        challengeContainerStackView.arrangedSubviews
            .first(where: { $0 is BiometricsView })?.isHidden = !biometricsHelper.biometricAuthEnabled
    }

    private func update(launchPageItems items: [LaunchPageItem]) {
        launchPageItemStackView.removeAllViews()
        launchPageItems = items

        guard !items.isEmpty else {
            moreItems = []
            return
        }

        let buttons = items.enumerated().map { (index, item) -> UIButton in
            let button = componentFactory.createButton(style: .buttonNoOutlineOnLogin, l10nKey: nil)
            button.setTitle(item.name, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(launchPageItemTapped(_:)), for: .touchUpInside)
            return button
        }

        let bisection = { () -> Int in
            var availableWidth = launchPageItemContainerView.bounds.width

            let spacingWidth = launchPageItemStackView.spacing * 2 + dividerWidth
            let buttonWidths = buttons.map { $0.intrinsicContentSize.width }

            // Determine what the required width would be if each button were the last displayed button.
            let requiredWidths = buttonWidths
                .enumerated()
                .map { (index, width) -> CGFloat in
                    switch index {
                    case buttons.startIndex:
                        return width
                    default:
                        return width + spacingWidth
                    }
                }
                .scan(initial: 0, nextPartialResult: +)

            if let lastRequiredWidth = requiredWidths.last, lastRequiredWidth <= availableWidth {
                // All items fit
                return items.endIndex
            }

            let moreButtonWidth = moreButton.intrinsicContentSize.width + spacingWidth
            availableWidth -= moreButtonWidth

            if let index = requiredWidths.firstIndex(where: { $0 > availableWidth }) {
                // If we are showing the More menu, ensure there are at least 2 items in it
                return index
                    .upperBounded(by: items.endIndex - 2)
                    .lowerBounded(by: 0)
            }

            // Shouldn't be possible to reach this point
            assertionFailure("Invalid launch page menu item width calculation")
            return requiredWidths.endIndex
        }()

        var head = buttons[..<bisection]
        let tail = items[bisection...]

        if !tail.isEmpty {
            head.append(moreButton)
        }
        for (index, button) in head.enumerated() {
            if index > head.startIndex {
                let divider = componentFactory.createView(style: .backgroundDefault)
                divider.snp.makeConstraints { (make) in
                    make.width.equalTo(1)
                }
                launchPageItemStackView.addArrangedSubview(divider)
            }
            launchPageItemStackView.addArrangedSubview(button)
        }

        moreItems = Array(tail)
    }

    private var selfCustomerEnrollmentURL: URL? {
        return companyAttributes
            .companyAttributes
            .value?
            .value(forKey: "consumerAuthentication.selfenrollment.launchPage.url")
            .flatMap(URL.init(string:))
    }

    private var selfBusinessEnrollmentURL: URL? {
        return companyAttributes
            .companyAttributes
            .value?
            .value(forKey: "businessAuthentication.selfenrollment.launchPage.url")
            .flatMap(URL.init(string:))
    }

    private func evaluateLogOutErrorMessage() {
        // If user was logged out by a webToNative call the message will be stored as KeyStore.logOutErrorMessage
        if let logOutErrorMessage = userDefaults.object(key: KeyStore.logOutErrorMessage) as? String {
            showAlert(message: logOutErrorMessage)
            userDefaults.removeValue(key: KeyStore.logOutErrorMessage)
        }
    }

    private func updateLaunchPageButtons() {
        let snapshotEnabled = companyAttributes
            .companyAttributes
            .value?
            .boolValue(forKey: "bankingLogin.snapshot.enabled") ?? true

        let selfCustomerEnrollmentEnabled = companyAttributes
            .companyAttributes
            .value?
            .boolValue(forKey: "consumerAuthentication.selfenrollment.enabled") ?? true

        let selfBusinessEnrollmentEnabled = companyAttributes
            .companyAttributes
            .value?
            .boolValue(forKey: "businessAuthentication.selfenrollment.enabled") ?? true

        let snapshotLabelTitle = self.currentTabIndex == 0 ?
            l10nProvider.localize("launchPage.snapshot.button.label") :
            l10nProvider.localize("login.business.btn.snapshot")

        let selfEnrollmentTitle = self.currentTabIndex == 0 ?
            l10nProvider.localize("launchPage.selfEnrollment.label") :
            l10nProvider.localize("login.business.self.enrollment")

        selfEnrollmentButton.setTitle(selfEnrollmentTitle, for: .normal)
        snapshotButton.setTitle(snapshotLabelTitle, for: .normal)
        snapshotButton.isHidden = !snapshotEnabled

        switch currentTabIndex {
        case 0:
            selfEnrollmentButton.isHidden = !selfCustomerEnrollmentEnabled || selfCustomerEnrollmentURL == nil
        case 1:
            selfEnrollmentButton.isHidden = !selfBusinessEnrollmentEnabled || selfBusinessEnrollmentURL == nil
        default:
        break
        }
    }

    private func updateLaunchPageFooter() {
        copyrightLabel.text = l10nProvider.localize(
            "app.footer.legal.copyright",
            parameterMap: [
                "year": Calendar.current.component(.year, from: Date())
            ]
        )
        copyrightSecondLineLabel.text = l10nProvider.localize("app.footer.legal.copyright.secondary")
        versionLabel.text = "v\(bundle.stringValueForKey("CFBundleShortVersionString") ?? "")"
    }

    @IBAction func snapshotButtonTapped(_ sender: Any) {
        cancelables.cancel()
        if let token = viewModel.snapshotToken {
            presenter.presentSnapshot(withToken: token, from: self)
        } else {
            showGenericError(
                title: l10nProvider.localize("device.enable-snapshot.title"),
                message: l10nProvider.localize("dashboard.quick-view.marketing-message")
            )
        }
    }

    @IBAction func selfEnrollmentButtonTapped(_ sender: Any) {
        cancelables.cancel()
        switch currentTabIndex {
        case 0:
            if let url = selfCustomerEnrollmentURL {
                presenter.presentSelfEnrollment(url: url, from: self)
            }
        case 1:
            let url = selfBusinessEnrollmentURL
            presenter.present(dialogType: .enrollment(url: url), from: self)
        default:
            break
        }
    }

    @objc func launchPageItemTapped(_ sender: UIButton) {
        cancelables.cancel()
        let index = sender.tag
        let launchPageItem = launchPageItems[index]
        select(launchPageItem: launchPageItem)
    }

    @objc func moreButtonTapped(_ sender: UIButton) {
        cancelables.cancel()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for item in moreItems {
            alert.addAction(UIAlertAction(title: item.name, style: .default, handler: { [weak self] (_) in
                self?.select(launchPageItem: item)
            }))
        }
        alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.cancel"), style: .cancel))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(alert, animated: true)
    }

    @IBAction func viewTapped(_ sender: Any) {
        view.endEditing(true)
    }

    private func select(launchPageItem: LaunchPageItem) {
        presenter.present(launchPageItem: launchPageItem, from: self)
    }

    public func refreshChallenge() {
        challengeItemPresenters = []
        challengeItemsStackView.removeAllViews()
        challengeActionPresenters = []
        challengeActionsStackView.removeAllViews()
        displayLoadingView()
        getInitialChallenge()
    }

    private func displayLoadingView() {
        let presenter = ShimmeringViewPresenter<GenericShimmeringView>(
            bundle: ShimmeringDataBundle.bundle,
            styleKey: .shimmeringViewOnDefault,
            componentStyleProvider: componentStyleProvider
        )
        let view = presenter.createView()
        presenter.configure(view: view)
        challengeItemsStackView.addArrangedSubview(view)
    }

    private func getInitialChallenge() {
        // We want to make sure that we clear any session cookie that is present here to ensure that it is not sent back to the server
        // again. If it is sent back to the server, the server will continue to use it instead of generating a new session.
        if let sessionCookie = HTTPCookieStorage.shared.cookies(for: restServer.url)?.filter({ cookie in cookie.name == "SESSION" }).first {
            HTTPCookieStorage.shared.deleteCookie(sessionCookie)
        }

        challengeService
            .getChallenge()
            .subscribe { [unowned self] result in
                switch result {
                case .success(let challenge):
                    self.biometricsAutoPromptManager.didRecieveInitialChallenge()
                    self.processChallengeResponse(challenge: challenge)
                case .error(let error):
                    //TODO: Show refresh view
                    log.error("Error getting initial challenge \(error)", context: error)

                    if case let ResponseError.failureWithMessage(message) = error {
                        self.showGenericError(message: message)
                    } else {
                        self.showGenericError()
                    }
                }
            }
            .disposed(by: bag)
    }

    private func processChallengeResponse(challenge: ChallengeResponse, populateItemsFromSavedData: Bool = true) {
        self.challenge = challenge
        challengeItems = challenge.items
        if populateItemsFromSavedData {
            persistenceHelper.populateFields(in: challenge.items)
        }
        
        presenterFactory = ChallengePresenterFactory(
            challenge: challenge,
            componentStyleProvider: componentStyleProvider,
            l10nProvider: componentConfig.l10nProvider,
            persistenceHelper: persistenceHelper,
            companyAttributesHolder: companyAttributes
        )
        
        if isBusinessProductEnabled {
            currentTabIndex = persistenceHelper.loadCurrentTabIndex()
            tabSegmentView.isHidden = false
            tabSegmentPresenter = presenterFactory!.tabSegmentPresenters(currentTabIndex: currentTabIndex)
            tabSegmentView.subviews.forEach({ $0.removeFromSuperview() })
            tabSegmentPresenter.forEach { (tabSegmentPresenter) in
                let view = tabSegmentPresenter.createView()
                tabSegmentView.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                tabSegmentPresenter.configure(view: view)
                tabSegmentPresenter.delegate = self
            }
        } else {
            tabSegmentView.isHidden = true
        }
        
        loadPresenterView()
        updateLaunchPageButtons()
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private func loadPresenterView() {
        // Challenge Items with tabindex
        challengeItemPresenters = self.presenterFactory!.itemPresenters(withTabIndex: self.currentTabIndex)
        challengeItemsStackView.removeAllViews()
        challengeItemPresenters.forEach({ (anyPresentable) in
            let view = anyPresentable.createView()
            self.challengeItemsStackView.addArrangedSubview(view)
            anyPresentable.configure(view: view)

            if let textInputPresenter = anyPresentable.base as? ChallengeTextInputPresenter {
                textInputPresenter.delegate = self
            }
        })

        // Challenge Actions
        challengeActionPresenters = self.presenterFactory!.actionPresenters(withTabIndex: self.currentTabIndex)
        challengeActionsStackView.removeAllViews()
        challengeActionPresenters.forEach({ (actionPresenter) in
            let view = actionPresenter.createView()
            self.challengeActionsStackView.addArrangedSubview(view)
            actionPresenter.configure(view: view)
            actionPresenter.delegate = self
        })

        // Link buttons
        linkButtonPresenters = self.presenterFactory!.linkButtonPresenters(withTabIndex: self.currentTabIndex)
        linkButtonPresenters.forEach { (linkButtonPresenter) in
            let view = linkButtonPresenter.createView()
            self.challengeActionsStackView.addArrangedSubview(view)
            linkButtonPresenter.configure(view: view)
            linkButtonPresenter.delegate = self
        }
    }
}

extension AuthPrimaryViewController: ChallengeTabSegmentPresenterdelegate {
    func segmentValueChanged(challengeTabSegmentItems: ChallengeTabSegmentItems, tabsegment: UISegmentedControl) {
        self.currentTabIndex = tabsegment.selectedSegmentIndex
        persistenceHelper.persistCurrentTabIndex(currentTabIndex: self.currentTabIndex)
        loadPresenterView()
        updateLaunchPageButtons()
        getUpdateLaunchPageItemsForTabIndex()
        removePickerView()
    }
}

extension AuthPrimaryViewController: ChallengeActionPresenterDelegate {
    func buttonPressed(challengeButtonItem: ChallengeAction, button: UIButtonComponent, reCaptchaToken token: String? = nil) {
        if let eventName = challengeButtonItem.inAppRatingKey {
            inAppRatingManager.engage(event: eventName, fromViewController: self)
        }

        if challengeButtonItem.type == .submit {
            guard !reCaptchaRequired else {
                self.reCaptchaHelper?.performReCaptcha(inView: view)

                return
            }

            guard let currentChallenge = challenge else { return }
            var currentChallengeItems: [ChallengeItem] = []
            if self.currentTabIndex == 0 {
                currentChallengeItems = challengeItems.filter { $0.tabIndex == 0 }
            } else if self.currentTabIndex == 1 {
                currentChallengeItems = challengeItems.filter { $0.tabIndex == 1 }
            }

            guard currentChallengeItems.isEmpty
                || !challengeHelper.hasValidationErrors(in: currentChallengeItems) else {
                challengeHelper.reconfigureViews(
                    inPresenters: challengeItemPresenters,
                    withStackView: challengeItemsStackView)
                return
            }

            beginLoading(fromButton: button)

            var challengeToSend: ChallengeResponse
            if let recaptchaToken = token {
                challengeToSend = ChallengeResponse(
                    type: currentChallenge.type,
                    titles: currentChallenge.titles,
                    items: currentChallengeItems + [ChallengeReCaptchaItem(token: recaptchaToken)],
                    actions: currentChallenge.actions,
                    isAuthenticated: currentChallenge.isAuthenticated,
                    token: currentChallenge.token,
                    previousItems: currentChallenge.previousItems
                )
            } else {
                challengeToSend = ChallengeResponse(
                    type: currentChallenge.type,
                    titles: currentChallenge.titles,
                    items: currentChallengeItems,
                    actions: currentChallenge.actions,
                    isAuthenticated: currentChallenge.isAuthenticated,
                    token: nil,
                    previousItems: currentChallenge.previousItems
                )
            }

            challengeService
                .submit(challenge: ChallengeRequest(challengeToSend))
                .subscribe { [weak self] (event) in
                    switch event {
                    case .success(let challenge):
                        self?.handle(challenge: challenge)
                    
                    case .error(let error):
                        log.error("Error submitting challenge \(error)", context: error)

                        switch error {
                        case ResponseError.failureWithMessage(let message), ResponseError.unauthenticated(let message):
                            self?.showGenericError(message: message)
                        case ResponseError.requiresReCaptcha(let message):
                            self?.showGenericError(message: message)
                            self?.reCaptchaRequired = true
                        default:
                            self?.showGenericError()
                        }

                        self?.cancelables.cancel()
                    }
                }
                .disposed(by: cancelables)
        }
    }

    private func handle(challenge: ChallengeResponse) {
        self.persistenceHelper.persistCurrentTabIndex(currentTabIndex: self.currentTabIndex)
        if challenge.isAuthenticated {
            //if isauthenticates is true we are saving the user on savedusername list based on activeProfileTpe
            // as we get usersession only if authentication is true
            //assuming this method will call only if there are no extra challenge items/screens after clicking submit on first screen
            delegate?.authViewControllerAuthenticated(self, completionHandler: { userSession in
                guard let currentChallenge = self.challenge else { return }
                let activeProfileTypeIndex = userSession.rawSession?.activeProfileType == "BUSINESS" ? 1 : 0
                self.activeProfileIndex = activeProfileTypeIndex
                self.persistenceHelper.persistCurrentTabIndex(currentTabIndex: activeProfileTypeIndex)
                self.persistenceHelper.persistFields(in: currentChallenge.items,
                                                     currentTabIndex: self.currentTabIndex,
                                                     activeProfileTypeIndex: activeProfileTypeIndex)
            })
        } else {
            fetchMFAEnrollDataIfNeeded(for: challenge) { mfaEnrollResponse in
                let shouldSaveUsernameEnabled = self.isUsernameChecked()
                let username = self.getUsername()
                // If we have received an aditional challenge we want to strip out any token item(s)
                // that were returned as these are not presentable challenge items.
                self.delegate?.authViewController(
                    self,
                    receivedAdditionalChallenge: challenge.challengeResponseStrippingNonPresentableItems(),
                    receivedAdditionalMFAEnrollResponse: mfaEnrollResponse,
                    shouldSaveUsernameEnabled: shouldSaveUsernameEnabled,
                    username: username
                )
            }
        }

        biometricsAutoPromptManager.transitionedPastPrimaryView()
    }
    
    private func openDeleteUserNamesView() {
        let controller = SavedUsernamesViewController(
            componentConfig: componentConfig,
            persistenceHelper: persistenceHelper,
            currentTabIndex: self.currentTabIndex)
        controller.delegate = self
        let navigationController = UINavigationControllerComponent(rootViewController: controller)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func isUsernameChecked() -> Bool? {
        if (self.currentTabIndex == 0) {
            guard let shouldSaveUsername = challengeItems
                .first(where: { $0.challengeName == ChallengeName.saveUsername.rawValue }) as? ChallengeCheckboxItem else { return nil }
            return shouldSaveUsername.value
        } else {
            guard let shouldSaveBusinessUsername = challengeItems
                .first(where: { $0.challengeName == ChallengeName.saveBusinessUsername.rawValue }) as? ChallengeCheckboxItem
            else { return nil }
            return shouldSaveBusinessUsername.value
        }
    }
    
    private func getUsername() -> String? {
        if (self.currentTabIndex == 0) {
            guard let username = challengeItems
                .first(where: { $0.challengeName == ChallengeName.username.rawValue }) as? ChallengeTextInputItem else { return nil }
            return username.value ?? nil
        } else {
        guard let businessUsername = challengeItems
            .first(where: { $0.challengeName == ChallengeName.business_username.rawValue }) as? ChallengeTextInputItem else { return nil }
            return businessUsername.value ?? nil
        }
    }

    private func showGenericError(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(
            title: title ?? l10nProvider.localize("app.error.generic.title"),
            message: message ?? l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func hideBiometricsView(hidden: Bool) {
        challengeContainerStackView.arrangedSubviews
            .first(where: { $0 is BiometricsView })?.isHidden = hidden
        biometricPresenter?.stopSpinner()
        cancelables.cancel()
    }
}

extension AuthPrimaryViewController: TrackableScreen {
    public var screenName: String {
        return "Authentication"
    }
    
    private func getUpdateLaunchPageItemsForTabIndex() {
        var profileType: String
        profileType = self.isBusinessProductEnabled ? (self.currentTabIndex == 0 ? "CONSUMER": "BUSINESS") : ""
        
        challengeService.launchPageItems(profileType: profileType)
            .subscribe(onSuccess: { [unowned self] (items) in
                self.update(launchPageItems: items)
            }, onError: { (error) in
                log.error("Error fetching launch page items: \(error)", context: error)
            })
    }
}

extension AuthPrimaryViewController: BiometricsPresenterDelegate {
    func biometricButtonPressed() {
        let analyticsName = (self.biometricsHelper.supportedBiometricType == .faceId)
            ? "LoginWithFaceID"
            : "LoginWithTouchID"
        self.analyticsTracker.trackEvent(AnalyticsEvent(category: "AUTHENTICATION", action: .click, name: analyticsName))
        authenticateWithBiometrics()
    }

    private func authenticateWithBiometrics() {
        guard !biometricsHelper.domainStateChanged else {
            delegate?.authViewControllerNeedsBiometricEnrollment(.reEnroll)
            showBiometricDisabledAlert()
            return
        }
        guard let challenge = challenge else { return }

        beginLoading()
        self.biometricPresenter?.startSpinner()

        biometricsHelper
            .retrieveToken()
            .do(onSuccess: { _ in
                if self.biometricsHelper.supportedBiometricType == .faceId {
                    self.inAppRatingManager.engage(event: "faceId:auth:acquired", fromViewController: self)
                } else if self.biometricsHelper.supportedBiometricType == .touchId {
                    self.inAppRatingManager.engage(event: "fingerprint:auth:acquired", fromViewController: self)
                }
            })
            .flatMap({ [unowned self] (token) -> Single<ChallengeResponse> in
                let tokenItem = ChallengeDeviceTokenItem(token: token)
                let uuidItem = ChallengeDeviceUUIDItem(uuid: self.uuid.uuidString)

                let newChallenge = ChallengeResponse(
                    type: "BIOMETRIC",
                    titles: challenge.titles,
                    items: [tokenItem, uuidItem],
                    actions: challenge.actions,
                    isAuthenticated: challenge.isAuthenticated,
                    token: challenge.token,
                    previousItems: challenge.previousItems
                )

                return self.challengeService.submit(challenge: ChallengeRequest(newChallenge))
            })
            .observeOn(MainScheduler.instance)
            .subscribe({ [unowned self] event in
                switch event {
                case .success(let challenge):
                    let analyticsName = (self.biometricsHelper.supportedBiometricType == .faceId)
                        ? "FACE_ID"
                        : "TOUCH_ID"
                    self.analyticsTracker.trackEvent(AnalyticsEvent(category: "AUTHENTICATION", action: .result, name: analyticsName))

                    // We are providing a synthetic interaction event since a user may
                    // not have had to 'touch' the screen to get to this point with
                    // faceId autoprompting them
                    self.userInteraction.triggerUserInteraction()

                    // If we have a device token item we need to persist the token.
                    if let token = (challenge.items.first(where: { $0 is ChallengeDeviceTokenItem }) as? ChallengeDeviceTokenItem)?.token {
                        try? self.biometricsHelper.updateToken(token: token)
                    }

                    self.handle(challenge: challenge)
                case .error(let error):
                    switch error {
                    case BiometricsHelperItem.Error.authenticationFailed:
                        // In the case that the app was in the background and has come back to the foreground
                        // we want to swallow the authentication failed error and re-prompt the user to login with
                        // biometrics.

                        switch self.activeState {
                        case .returningFromInactive:
                            self.authenticateWithBiometrics()
                        case .active:
                            self.showBiometricAuthError()
                        case .goingToInactive:
                            break
                        }
                    case BiometricsHelperItem.Error.biometryLocked:
                        self.showBiometricDisabledAlert()
                    case BiometricsHelperItem.Error.userCancelled:
                        break
                    case BiometricsHelperItem.Error.generalError:
                        self.showGenericError(message: nil)
                        log.error("Error authenticating with biometrics \(error)", context: error)
                    case ResponseError.failureWithMessage(let message):
                        self.showGenericError(message: message)
                    case ResponseError.unauthenticated(let message):
                        delegate?.authViewControllerNeedsBiometricEnrollment(.reEnroll)
                        self.showGenericError(message: message)
                        self.refreshBiometrics()
                    default:
                        self.showGenericError(message: nil)
                    }

                    switch error {
                    case BiometricsHelperItem.Error.userCancelled:
                        let analyticsName = (self.biometricsHelper.supportedBiometricType == .faceId)
                            ? "CancelLogInWithFaceID"
                            : "CancelLogInWithTouchID"
                        self.analyticsTracker.trackEvent(AnalyticsEvent(category: "AUTHENTICATION", action: .click, name: analyticsName))
                    default:
                        let analyticsName = (self.biometricsHelper.supportedBiometricType == .faceId)
                            ? "FACE_ID_FAIL"
                            : "TOUCH_ID_FAIL"
                        self.analyticsTracker.trackEvent(AnalyticsEvent(category: "AUTHENTICATION", action: .result, name: analyticsName))
                    }

                    self.biometricPresenter?.stopSpinner()
                    self.cancelables.cancel()
                }

                self.biometricsAutoPromptManager.biometricsPromptShown()
            })
            .disposed(by: cancelables)
    }

    private func showBiometricDisabledAlert() {
        let message = (biometricsHelper.supportedBiometricType == .faceId)
            ? l10nProvider.localize("login.error.faceid.ios.dataUpdated")
            : l10nProvider.localize("login.error.fingerprint.ios.dataUpdated")
        showAlert(message: message)
    }

    private func showBiometricAuthError() {
        let message = (biometricsHelper.supportedBiometricType == .faceId)
            ? l10nProvider.localize("login.error.faceid.ios")
            : l10nProvider.localize("login.error.fingerprint.ios")
        showAlert(message: message)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: l10nProvider.localize("alert.standard.title"),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension AuthPrimaryViewController: BiometricsEnrollmentPresenterDelegate {
    func biometricEnrollmentCheckboxChanged(checkbox: UICheckboxComponent) {
        delegate?.authViewControllerNeedsBiometricEnrollment((checkbox.checkState == .checked) ? .enroll : .none)
    }
}

extension AuthPrimaryViewController: ChallengeTextInputPresenterDelegate {
    func editingEnded(forTextField textField: UITextField, inPresenter presenter: ChallengeTextInputPresenter) {
        _ = presenter.challenge.validate(type: .focusChange)

        challengeHelper.reconfigureView(
            forPresenter: AnyViewPresentable(presenter),
            inPresenters: challengeItemPresenters,
            withStackView: challengeItemsStackView
        )
    }

    func rightButtonPressed(button: UIButton, inPresenter presenter: ChallengeTextInputPresenter) {
        inAppRatingManager.engage(event: "login:help:touched", fromViewController: self)
        guard let challengeButton = presenter.challenge.button else { return }
        if let buttonType = challengeButton.buttonDialog?.type, buttonType == .businessTooltipDialog {
            self.presenter.present(dialogType: .toolTip, from: self)
        } else if let url = challengeButton.url {
            self.presenter.presentHelpView(url: url, from: self)
        }
    }

    func usernameButtonPressed() {
        getPickerItemsArray()
        if (usernamesPickerContainer == nil) {
            let usernamesPicker = UIPickerView()
            usernamesPicker.translatesAutoresizingMaskIntoConstraints = false
            usernamesPickerView = usernamesPicker
            
            usernamesPicker.delegate = self
            usernamesPicker.dataSource = self
            usernamesPicker.backgroundColor = .white
            usernamesPicker.setValue(UIColor.black, forKeyPath: "textColor")
            
            let tapToSelect = UITapGestureRecognizer(target: self, action: #selector(pickerTapped))
            tapToSelect.delegate = self
            usernamesPicker.addGestureRecognizer(tapToSelect)
            
            let doneButton = UIBarButtonItem(title: l10nProvider.localize("login.multiprofile.btn.done"),
                                             style: .done,
                                             target: self,
                                             action: #selector(doneTapped))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let toolBar = UIToolbar()
            toolBar.isTranslucent = true
            toolBar.isUserInteractionEnabled = true
            toolBar.setItems([spaceButton, doneButton], animated: false)
            
            usernamesPickerContainer = UIStackView(arrangedSubviews: [toolBar, usernamesPicker], axis: .vertical)
            view.addSubview(usernamesPickerContainer)
            usernamesPickerContainer.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            
        } else {
            usernamesPickerView?.reloadAllComponents()
        }
    }
    
    func removePickerView() {
        if let pickerviewContainer = usernamesPickerContainer {
            pickerviewContainer.removeFromSuperview()
            usernamesPickerContainer = nil
        }
    }
}

extension AuthPrimaryViewController: SavedUsernamesDelegate {
    func usernameSelected(_ username: String) {
        guard let challenge = challenge else { return }
        let newChallengeItems = challengeItems.filter { $0.tabIndex == self.currentTabIndex }
        let challengeName: ChallengeName = currentTabIndex == 0 ? .username : .business_username
        let usernameItem = newChallengeItems.first { $0.challengeName == challengeName.rawValue } as? ChallengeTextInputItem
        usernameItem?.maskedValue = username.masked()
        usernameItem?.value = username
        let newChallenge = ChallengeResponse(
            type: challenge.type,
            titles: challenge.titles,
            items: challengeItems,
            actions: challenge.actions,
            isAuthenticated: challenge.isAuthenticated,
            token: nil,
            previousItems: challenge.previousItems
        )
        let biometricsView = challengeContainerStackView.arrangedSubviews.first(where: { $0 is BiometricsView })
        let hideBiometrics = (!persistenceHelper.enableBiometrics && biometricsView?.isHidden == true)
            || !biometricsHelper.biometricAuthEnabled
        hideBiometricsView(hidden: hideBiometrics)
        processChallengeResponse(challenge: newChallenge, populateItemsFromSavedData: false)
    }

    func usernameDeleted(_ username: String) {
        guard let challenge = challenge else { return }
        
        let targetNames = Set([ChallengeName.username.rawValue, ChallengeName.business_username.rawValue])
        let usernameItems = challenge.items
            .filter { targetNames.contains($0.challengeName) }.compactMap { $0 as? ChallengeTextInputItem }
        for item in usernameItems where item.value == username {
            item.value = nil
            item.maskedValue = nil
        }
        
        processChallengeResponse(challenge: challenge)
    }
}

extension AuthPrimaryViewController: ChallengeServiceDelegate {
    public func currentChallengeType() -> String? {
        return challenge?.type
    }
}

extension AuthPrimaryViewController: AuthPresenterDelegate {
    public func presenter(_ presenter: AuthPresenter, didReceiveData data: [String: String]) {
        // We are catching the errormessage which is sent from unexpected logout action web.
        if let alertMessage = data["errorMessage"] {
            showAlert(message: alertMessage)
        }

        // Currently we are only handling a username that is handed back to us from a forgot username screen. This
        // may be used for more in the future. We are also making the assumption that we are showing the username
        // challenge as the first challenge item.
        guard let username = data["username"] else { return }
        setTextChallengeValue(username, forChallenge: .username)
    }
}

extension AuthPrimaryViewController: ReCaptchaHelperDelegate {
    func reCaptchaDidSucceed(withToken token: String) {
        self.reCaptchaRequired = false

        guard let submitAction = challengeActionPresenters
            .first(where: { actionPresenter in actionPresenter.challenge.type == .submit }) else { return }
        guard let button = submitAction.view?.button else { return }

        buttonPressed(challengeButtonItem: submitAction.challenge, button: button, reCaptchaToken: token)
    }

    func reCaptchaFailed(withError error: ReCaptchaError) {
        log.debug(error)
        self.reCaptchaRequired = true
        showGenericError(message: l10nProvider.localize("login.recaptcha.failed"))
    }
}

extension AuthPrimaryViewController: ChallengeLinkButtonItemsPresenterDelegate {
    func present(url: URL) {
        presenter.presentSelfEnrollment(url: url, from: self)
    }

    func present(dialog: AuthDialogType) {
        presenter.present(dialogType: dialog, from: self)
    }
}

extension AuthPrimaryViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItemsArray.count
    }
}

extension AuthPrimaryViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItemsArray[row]
    }
}

extension AuthPrimaryViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                                    otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension AuthPrimaryViewController {
    func selectPickerRow(_ row: Int) {
        switch row {
        case pickerItemsArray.count - 1:
            openDeleteUserNamesView()
        case pickerItemsArray.count - 2:
            if let textField = challengeItemsStackView.subviews[0] as? ChallengeTextInputView {
                textField.textField.text = ""
                textField.textField.placeholder = l10nProvider.localize("login.enterusername.text")
            }
        default:
            let selectedUser = persistenceHelper.savedUsernames(currentTabIndex: currentTabIndex)[row]
            self.persistenceHelper.saveUsername(username: selectedUser,
                                                currentTabIndex: self.currentTabIndex,
                                                activeProfileTypeIndex: self.currentTabIndex)
            usernameSelected(selectedUser)
        }
        removePickerView()
    }
    
    @objc func pickerTapped(_ tapRecognizer: UITapGestureRecognizer) {
        if let usernamesPickerView = self.usernamesPickerView, tapRecognizer.state == .ended {
            let rowHeight = usernamesPickerView.rowSize(forComponent: 0).height
            let selectedRowFrame = usernamesPickerView.bounds.insetBy(dx: 0, dy: (usernamesPickerView.frame.height - rowHeight) / 2)
            let userTappedOnSelectedRow = selectedRowFrame.contains(tapRecognizer.location(in: usernamesPickerView))
            if userTappedOnSelectedRow {
                selectPickerRow(usernamesPickerView.selectedRow(inComponent: 0))
            }
        }
    }
    
    @objc func doneTapped() {
        selectPickerRow(usernamesPickerView!.selectedRow(inComponent: 0))
    }
}

private extension AuthPrimaryViewController {
    func setTextChallengeValue(_ value: String?,
                               maskedValue: String? = nil,
                               forChallenge challenge: ChallengeName) {
        guard let presenter = challengeItemPresenters.first(where: {
            if let textInputPresenter = $0.base as? ChallengeTextInputPresenter,
               textInputPresenter.challenge.challengeName == challenge.rawValue {
                return true
            }
            return false
        })?.base as? ChallengeTextInputPresenter else {
            return
        }
        presenter.challenge.value = value
        presenter.challenge.maskedValue = maskedValue
        
        challengeHelper.reconfigureView(
            forPresenter: AnyViewPresentable(presenter),
            inPresenters: challengeItemPresenters,
            withStackView: challengeItemsStackView
        )
    }
}

private extension AuthPrimaryViewController {
    func fetchMFAEnrollDataIfNeeded(for response: ChallengeResponse,
                                 onCompletion completion: @escaping((MFAEnrollmentResponse?) -> Void)) {
        if response.type == "MFA_ENROLL" {
            mfaEnrollmentService.disclosure().subscribe { response in
                completion(response)
            } onError: { _ in
                completion(nil)
            }.disposed(by: cancelables)
        } else {
            completion(nil)
        }
    }
}
