//
//  AuthSecondaryViewController.swift
//  Authentication
//
//  Created by Chris Carranza on 6/20/18.
//

import AuthGenericViewController
import Biometrics
import ComponentKit
import CompanyAttributes
import InAppRatingApi
import Localization
import Logging
import Network
import SnapKit
import UIKit
import Utilities
import ViewPresentable
import Analytics

public final class AuthSecondaryViewController: AuthGenericViewController, AuthViewController {
    @IBOutlet weak var challengeItemsStackView: UIStackView!
    
    private let challenge: ChallengeResponse
    private let mfaEnrollmentResponse: MFAEnrollmentResponse?
    private let challengeService: ChallengeService
    
    private let companyAttributes: CompanyAttributesHolder
    private let presenters: [AnyViewPresentable]
    private let presenterFactory: ChallengePresenterFactory
    private let challengeActionPresenters: [ChallengeActionPresenter]
    private var challengeItems: [ChallengeItem] = []
    private let challengeHelper = ChallengeHelper()
    private let inAppRatingManager: InAppRatingManager
    private let biometricsHelper: BiometricsHelper
    fileprivate let presenter: AuthPresenter
    private let currentTabIndex: Int
    private let shouldSaveUsernameEnabled: Bool?
    private let username: String?
    private let persistenceHelper: ChallengePersistenceHelper
    private var isBusinessProductEnabled: Bool

    public weak var delegate: AuthDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         challenge: ChallengeResponse,
         mfaEnrollmentResponse: MFAEnrollmentResponse?,
         challengeService: ChallengeService,
         presenter: AuthPresenter,
         inAppRatingManager: InAppRatingManager,
         biometricsHelper: BiometricsHelper,
         companyAttributes: CompanyAttributesHolder,
         persistenceHelper: ChallengePersistenceHelper,
         shouldSaveUsernameEnabled: Bool?,
         username: String?) {
        self.challenge = challenge
        self.mfaEnrollmentResponse = mfaEnrollmentResponse
        self.challengeItems = challenge.items
        self.challengeService = challengeService
        self.presenter = presenter
        self.inAppRatingManager = inAppRatingManager
        self.biometricsHelper = biometricsHelper
        self.currentTabIndex = persistenceHelper.loadCurrentTabIndex()
        self.persistenceHelper = persistenceHelper
        self.shouldSaveUsernameEnabled = shouldSaveUsernameEnabled
        self.username = username
        self.companyAttributes = companyAttributes
        
        self.isBusinessProductEnabled = self.companyAttributes
            .companyAttributes.value?.boolValue(forKey: "businessAuthentication.businessTab.enabled") ?? false
        
        self.presenterFactory = ChallengePresenterFactory(
            challenge: challenge,
            componentStyleProvider: componentStyleProvider,
            l10nProvider: l10nProvider,
            persistenceHelper: persistenceHelper,
            companyAttributesHolder: companyAttributes
        )

        challengeActionPresenters = presenterFactory.actionPresenters(withTabIndex: self.currentTabIndex)
        
        presenters = presenterFactory.titlePresenters().filter { $0.challengeTitle.titleType.isHeader }.map { AnyViewPresentable($0) }
            + presenterFactory.itemPresenters(withTabIndex: self.currentTabIndex)
            + presenterFactory.titlePresenters().filter { $0.challengeTitle.titleType.isFooter }.map { AnyViewPresentable($0) }

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
        
        self.challengeService.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let rootView = AuthenticationBundle
            .bundle
            .loadNibNamed("AuthSecondaryView", owner: self, options: nil)?.first as! UIView
        containerView.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make
                .edges
                .equalTo(containerView)
        }
        
        presenters.forEach { (anyPresentable) in
            let view = anyPresentable.createView()
            self.challengeItemsStackView.addArrangedSubview(view)
            
            if let radioPresenter = anyPresentable.base as? ChallengeRadioButtonItemPresenter {
                radioPresenter.delegate = self
            } else if let newQuestionPresenter = anyPresentable.base as? ChallengeNewQuestionItemPresenter {
                newQuestionPresenter.delegate = self
            } else if let textInputPresenter = anyPresentable.base as? ChallengeTextInputPresenter {
                textInputPresenter.delegate = self
            }
        }
        
        configureChallengePresentables()
        
        challengeActionPresenters.forEach { (challengeActionPresentable) in
            let view = challengeActionPresentable.createView()
            self.buttonsStackView.addArrangedSubview(view)
            challengeActionPresentable.configure(view: view)
            
            challengeActionPresentable.delegate = self
        }
        
        if let mfaEnrolmentResponse = self.mfaEnrollmentResponse {
            let uilabel = UILabel()
            uilabel.numberOfLines = 0
            let data = Data(mfaEnrolmentResponse.content.utf8)
            if let attributedString = try? NSAttributedString(data: data,
                                                              options: [.documentType: NSAttributedString.DocumentType.html],
                                                              documentAttributes: nil) {
                uilabel.attributedText = attributedString
            }
            self.challengeItemsStackView.addArrangedSubview(uilabel)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let message = presenterFactory.message() {
            showMessageAlert(forMessage: message)
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cancelables.cancel()
    }
    
    func configureChallengePresentables() {
        for (index, view) in challengeItemsStackView.arrangedSubviews.enumerated() {
            presenters[index].configure(view: view)
        }
    }

    private func showMessageAlert(forMessage message: ChallengeTitle) {
        let title: String = message.titleType == .error
            ? l10nProvider.localize("app.error.generic.title")
            : l10nProvider.localize("alert.standard.title")

        let alert = UIAlertController(title: title, message: message.text, preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: nil)
        )

        present(alert, animated: true, completion: nil)
    }
    
    private func beginLoading(fromButton button: UIButtonComponent) {
        cancelables.cancel()
        
        let controls = view.descendantViews.compactMap { $0 as? UIControl }
        
        button.isLoading = true
        controls.forEach { $0.isEnabled = false }
        
        cancelables.insert {
            button.isLoading = false
            controls.forEach { $0.isEnabled = true }
        }
    }

    @IBAction func viewTapped(_ sender: Any) {
        view.endEditing(true)
    }
}

extension AuthSecondaryViewController: TrackableScreen {
    public var screenName: String {
        return "Authentication"
    }
}

extension AuthSecondaryViewController: ChallengeActionPresenterDelegate {
    func buttonPressed(challengeButtonItem: ChallengeAction, button: UIButtonComponent, reCaptchaToken token: String? = nil) {
        if let event = challengeButtonItem.inAppRatingKey {
            inAppRatingManager.engage(event: event, fromViewController: self)
        }

        let handler = {
            switch challengeButtonItem.type {
            case .submit:
                guard !self.challengeHelper.hasValidationErrors(in:
                    self.challengeItems.filter { $0.tabIndex == nil || $0.tabIndex == self.currentTabIndex }) else {
                    self.challengeHelper.reconfigureViews(inPresenters: self.presenters, withStackView: self.challengeItemsStackView)
                    
                    return
                }
                
                self.handleSubmit(challengeButtonItem: challengeButtonItem, button: button)
            case .cancel:
                self.handleCancel(challengeButtonItem: challengeButtonItem, button: button)
            case .back:
                self.handleBack(challengeButtonItem: challengeButtonItem, button: button)
            case .oobResend:
                self.handleOOBResend(challengeButtonItem: challengeButtonItem, button: button)
            case .generic:
                self.handleGeneric(challengeButtonItem: challengeButtonItem, button: button)
            case .cancelAbort:
                self.handleGeneric(challengeButtonItem: challengeButtonItem, button: button)
            }
        }
        
        if let dialog = challengeButtonItem.dialog {
            let alert = UIAlertController(
                title: dialog.title ?? l10nProvider.localize("alert.standard.title"),
                message: dialog.message,
                preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(title: dialog.cancel, style: .cancel, handler: nil)
            )
            
            alert.addAction(
                UIAlertAction(title: dialog.confirm, style: .default) { (_) in
                    handler()
                }
            )
            
            present(alert, animated: true)
        } else {
            handler()
        }
    }

    private func handleSubmit(challengeButtonItem: ChallengeAction, button: UIButtonComponent) {
        beginLoading(fromButton: button)
        
        let requestChallenge = ChallengeRequest(challenge)
        // tab Index nil check is for Secret question.
        requestChallenge.items = requestChallenge.items.filter { $0.tabIndex == nil || $0.tabIndex == self.currentTabIndex }
        
        challengeService.submit(challenge: requestChallenge)
            .subscribe { [weak self] (result) in
                switch result {
                case .success(let challenge):
                    self?.handle(challenge: challenge)

                case .error(let error):
                    log.error(
                        "Error submiting challenge in AuthSecondaryViewController: \(error)",
                        context: error
                    )
                    self?.handleResponseError(error)
                    self?.cancelables.cancel()
                }
            }
            .disposed(by: cancelables)
    }
    
    private func handleGeneric(challengeButtonItem: ChallengeAction, button: UIButtonComponent) {
        guard let challengeString = challengeButtonItem.challenge else {
            return
        }
        
        do {
            let challenge = try JSONSerialization
                .jsonObject(with: challengeString.data(using: .utf8)!, options: []) as! [String: Any]
            
            beginLoading(fromButton: button)
            
            challengeService.submit(challenge: challenge)
                .subscribe { [weak self] (result) in
                    switch result {
                    case .success(let challenge):
                        self?.handle(challenge: challenge)
                        
                    case .error(let error):
                        log.error(
                            "Error submiting challenge in AuthSecondaryViewController: \(error)",
                            context: error
                        )
                        self?.handleResponseError(error)
                        self?.cancelables.cancel()
                    }
                }
                .disposed(by: cancelables)
        } catch {
            print(error)
        }
    }

    private func handleCancel(challengeButtonItem: ChallengeAction, button: UIButtonComponent) {
        guard let challengeString = challengeButtonItem.challenge else { return }
        
        do {
            let currentChallenge = try JSONSerialization
                .jsonObject(with: challengeString.data(using: .utf8)!, options: []) as! [String: Any]
            
            beginLoading(fromButton: button)
            
            challengeService.cancel(challenge: currentChallenge)
                .subscribe { [weak self] (result) in
                    switch result {
                    case .success:
                        if let strongSelf = self {
                            strongSelf.delegate?.authViewControllerCanceled(strongSelf)
                        }
                    case .error(let error):
                        log.error("Error handling cancel in challenge flow: \(error)", context: error)
                        self?.handleResponseError(error)
                        self?.cancelables.cancel()
                    }
                }
                .disposed(by: cancelables)
        } catch {
            print(error)
        }
    }

    private func handleBack(challengeButtonItem: ChallengeAction, button: UIButtonComponent) {
        // The only time there should ever be a challenge attached to the back
        // action is on the new mfa oob challenge.
        guard let challengeString = challengeButtonItem.challenge else {
            delegate?.authViewControllerBackActionTaken(self)
            return
        }

        do {
            let currentChallenge = try JSONSerialization
                .jsonObject(with: challengeString.data(using: .utf8)!, options: []) as! [String: Any]
            
            beginLoading(fromButton: button)
            
            challengeService.goBack(from: currentChallenge)
                .subscribe { [weak self] (result) in
                    switch result {
                    case .success(let challenge):
                        self?.handle(challenge: challenge)
                        self?.cancelables.cancel()
                    case .error(let error):
                        log.error("Error handling back action in challenge flow \(error)", context: error)
                        self?.handleResponseError(error)
                        self?.cancelables.cancel()
                    }
                }
                .disposed(by: cancelables)
        } catch {
            print(error)
        }
    }

    private func handleOOBResend(challengeButtonItem: ChallengeAction, button: UIButtonComponent) {
        beginLoading(fromButton: button)

        // We are just going to bounce the challenge we got back up to the server here to have the code resent.
        challengeService.submit(challenge: ChallengeRequest(challenge))
            .subscribe { [weak self] (result) in
                self?.cancelables.cancel()
                
                switch result {
                case .success:
                    // We don't actually want to process the challenge returned here otherwise
                    // we will be pushing another view controller with the same challenge content onto the stack.
                    // We will just eat the success here.
                    log.debug("Code was resent")
                case .error(let error):
                    log.error("Error submiting oob resend: \(error)", context: error)
                    self?.handleResponseError(error)
                }
            }
            .disposed(by: cancelables)
    }
    
    private func handle(challenge: ChallengeResponse) {
        // If we have a device token item we need to persist the token.
        if let token = (challenge.items.first(where: { $0 is ChallengeDeviceTokenItem }) as? ChallengeDeviceTokenItem)?.token {
            try? self.biometricsHelper.updateToken(token: token)
        }
        
        if challenge.isAuthenticated {
            self.delegate?.authViewControllerAuthenticated(self, completionHandler: { userSession in
                // Need to store the username in the Auth store
                // If business product is not enabled by default, we just put the usernames as consumer.
                let activeProfileTypeIndex = !self.isBusinessProductEnabled ? 0
                    : userSession.rawSession?.activeProfileType == "BUSINESS" ? 1 : 0
                self.persistenceHelper.persistCurrentTabIndex(currentTabIndex: activeProfileTypeIndex)
                
                // If the Should save user name enabled in login page then save the temp
                if (self.shouldSaveUsernameEnabled != nil && !self.shouldSaveUsernameEnabled!) {
                    self.persistenceHelper.saveTempUserName(username: self.username, activeProfileTypeIndex: activeProfileTypeIndex)
                    return
                }
                
                // Save username in the Authstore
                if (self.username != nil) {
                    self.persistenceHelper.saveUsername(
                        username: self.username!,
                        currentTabIndex: self.currentTabIndex,
                        activeProfileTypeIndex: activeProfileTypeIndex)
                }
                
            })
        } else {
            // If we have received an aditional challenge we want to strip out any token item(s)
            // that were returned as these are not presentable challenge items.
            delegate?.authViewController(
                self,
                receivedAdditionalChallenge: challenge.challengeResponseStrippingNonPresentableItems(),
                receivedAdditionalMFAEnrollResponse: nil,
                shouldSaveUsernameEnabled: self.shouldSaveUsernameEnabled,
                username: username
            )
        }
    }

    private func handleResponseError(_ error: Error) {
        switch error {
        case ResponseError.failureWithMessage(let message), ResponseError.unauthenticated(let message):
            self.showErrorAlert(message: message)
        default:
            self.showErrorAlert()
        }
    }
}

extension AuthSecondaryViewController: ChallengeRadioButtonItemPresenterDelegate {
    func selectionChanged(presenter: ChallengeRadioButtonItemPresenter) {
        let index = presenters.firstIndex(of: AnyViewPresentable(presenter))!
        presenter.configure(view: challengeItemsStackView.arrangedSubviews[index] as! ChallengeRadioGroupView)
    }
}

extension AuthSecondaryViewController: ChallengeTextInputPresenterDelegate {
    func editingEnded(forTextField textField: UITextField, inPresenter presenter: ChallengeTextInputPresenter) {
        _ = presenter.challenge.validate(type: .focusChange)

        challengeHelper.reconfigureView(
            forPresenter: AnyViewPresentable(presenter),
            inPresenters: presenters,
            withStackView: challengeItemsStackView
        )
    }
    
    func rightButtonPressed(button: UIButton, inPresenter presenter: ChallengeTextInputPresenter) {
        guard let challengeButton = presenter.challenge.button else { return }

        inAppRatingManager.engage(event: "login:help:touched", fromViewController: self)

        self.presenter.presentHelpView(url: challengeButton.url, from: self)
    }

    func usernameButtonPressed() {}
}

extension AuthSecondaryViewController: ChallengeNewQuestionPresenterDelegate {
    func editingEnded(forTextField textField: UITextField, inPresenter presenter: ChallengeNewQuestionItemPresenter) {
        _ = presenter.challenge.validate(type: .focusChange)

        challengeHelper.reconfigureView(
            forPresenter: AnyViewPresentable(presenter),
            inPresenters: presenters,
            withStackView: challengeItemsStackView
        )
    }

    func newQuestionPresenter(_ presenter: ChallengeNewQuestionItemPresenter,
                              requestedQuestionChangeForChallenge challenge: ChallengeNewQuestionItem) {

        let questionSelectionVC = SecurityQuestionSelectionViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            challengePresenter: presenter,
            delegate: self
        )

        let navController = UINavigationController(rootViewController: questionSelectionVC)
        present(navController, animated: true)
    }
}

extension AuthSecondaryViewController: SecurityQuestionSelectionViewControllerDelegate {
    func questionSelectionViewController(_: SecurityQuestionSelectionViewController, doneButtonTouched button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func questionSelectionViewController(_: SecurityQuestionSelectionViewController,
                                         didSelectNewQuestion question: String,
                                         forChallengePresenter challengePresenter: ChallengeNewQuestionItemPresenter) {
        challengePresenter.challenge.selectedQuestion = question
        let index = self.presenters.firstIndex(of: AnyViewPresentable(challengePresenter))!
        challengePresenter.configure(view: self.challengeItemsStackView.arrangedSubviews[index] as! ChallengeNewQuestionView)
        self.dismiss(animated: true, completion: nil)
    }
}

extension AuthSecondaryViewController: ChallengeServiceDelegate {
    public func currentChallengeType() -> String? {
        return challenge.type
    }
}
