//
//  EmailVerificationsViewController.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import AuthGenericViewController
import CompanyAttributes
import ComponentKit
import Foundation
import Localization
import Logging
import Network
import PostAuthFlowController
import RxSwift
import Shimmer
import SnapKit
import UITableViewPresentation
import Utilities
import Analytics

public final class EmailVerificationViewController: AuthGenericViewController {
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var titleLabelView: UIView!
    @IBOutlet var patternLabelView: UIView!
    @IBOutlet var submitButton: UIButtonComponent!
    @IBOutlet var cancelButton: UIButtonComponent!
    
    private let serviceItem: EmailVerificationService
    private let postAuthFlowController: PostAuthFlowController

    private var presenters: [EmailInputPresenter] = []

    init(serviceItem: EmailVerificationService,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         postAuthFlowController: PostAuthFlowController) {
        self.serviceItem = serviceItem
        self.postAuthFlowController = postAuthFlowController

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        addEmailVerificationsSetupView(to: containerView)
        addCancelAndSubmitButtons(to: buttonsStackView)
        setupInputs()
    }

    private func addEmailVerificationsSetupView(to container: UIView) {
        let emailVerificationView = EmailVerificationBundle
            .bundle
            .loadNibNamed("EmailVerificationView", owner: self, options: [:])?
            .first as! UIView

        container.addSubview(emailVerificationView)

        emailVerificationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addCancelAndSubmitButtons(to stackView: UIStackView) {
        stackView.addArrangedSubview(submitButton)
        stackView.addArrangedSubview(cancelButton)
    }

    private func setupInputs() {
        self.submitButton.isHidden.toggle()
        self.cancelButton.isHidden.toggle()
        self.updatePresenters()
        self.contentStackView.addArrangedSubview(self.titleLabelView)
        self.addInputs(from: self.presenters, to: self.contentStackView)
        self.contentStackView.addArrangedSubview(self.patternLabelView)
    }

    private func getEmailInputView() -> EmailInputView {
        return EmailVerificationBundle
            .bundle
            .loadNibNamed("EmailInputView", owner: nil, options: [:])?
            .first as! EmailInputView
    }
    
    private func updatePresenters() {
        let emailInput = getEmailInputView(), confirmInput = getEmailInputView()

        presenters = [
            EmailInputPresenter(
                title: l10nProvider.localize("primaryEmailVerification.email.input"),
                view: emailInput,
                l10nProvider: l10nProvider,
                validators: getValidators()
            ),
            EmailInputPresenter(
                title: l10nProvider.localize("primaryEmailVerification.confirmEmail.input"),
                view: confirmInput,
                l10nProvider: l10nProvider,
                validators: getValidators(matchTo: emailInput)
            )
        ]
    }

    private func getValidators(matchTo otherInput: EmailInput? = nil) -> [EmailValidator] {
        let inputRequiredMsgKey = otherInput == nil ? "primaryEmailVerification.email.input.required"
            : "primaryEmailVerification.confirmEmail.input.required"
        var validators: [EmailValidator] = [
            EmailRegexValidator(
                errorMessage: l10nProvider.localize("primaryEmailVerification.email.input.invalid"),
                emptyErrorMessage: l10nProvider.localize(inputRequiredMsgKey)
            )
        ]
        if let otherInput = otherInput {
            let errorMsg = l10nProvider.localize("primaryEmailVerification.confirmEmail.input.match")
            validators.append(EmailMatchingValidator(otherInput: otherInput,
                                                     notMatchingErrorMessage: errorMsg))
        }
        return validators
    }

    private func addInputs(from presenters: [EmailInputPresenter], to stackView: UIStackView) {
        presenters.forEach {
            self.contentStackView.addArrangedSubview($0.view)
        }
    }

    private func cleanEmailVerify() {
        serviceItem
            .cleanEmailVerify()
            .subscribe(onSuccess: { [unowned self] _ in
                self.postAuthFlowController.advance()
            }, onError: { [unowned self] error in
                self.cancelables.cancel()

                if let error = error as? ResponseError,
                    case let ResponseError.failureWithMessage(message) = error {
                    self.showErrorAlert(message: message)
                } else {
                    self.showErrorAlert()
                }
            })
            .disposed(by: bag)
    }
    
    private func handleSubmit() {
        beginLoading(fromButton: submitButton)
        let email = presenters[0].email ?? ""

        serviceItem
            .postPrimaryEmail(email: email)
            .subscribe(onSuccess: { [unowned self] _ in
                self.cleanEmailVerify()
            }, onError: { [unowned self] error in
                self.cancelables.cancel()

                if let error = error as? ResponseError,
                    case let ResponseError.failureWithMessage(message) = error {
                    self.showErrorAlert(message: message)
                } else {
                    self.showErrorAlert()
                }
            })
            .disposed(by: bag)

        log.debug("Handling Submit")
    }

    private func showCancelAlert() {
        let alert = UIAlertController(
            title: l10nProvider.localize("primaryEmailVerification.cancelModal.title"),
            message: l10nProvider.localize("primaryEmailVerification.cancelModal.text"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("primaryEmailVerification.cancelModal.cancel"), style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("primaryEmailVerification.cancelModal.confirm"), style: .default) { _ in
                NotificationCenter.default.post(Notification(name: .loggedOut))
            }
        )

        present(alert, animated: true, completion: nil)
    }

    private func beginLoading(fromButton button: UIButtonComponent) {
        let controls = view.descendantViews.compactMap { $0 as? UIControl }

        button.isLoading = true
        controls.forEach { $0.isEnabled = false }

        cancelables.insert {
            button.isLoading = false
            controls.forEach { $0.isEnabled = true }
        }
    }

    @IBAction func submitButtonTouched(_ sender: UIButtonComponent) {
        // The validate method side effects to update the view so
        // order in the reduce closure matters. Validate is
        // done first so that it isn't short circuited.
        if presenters.allSatisfy({ $0.validate() }) {
            handleSubmit()
        }
    }

    @IBAction func cancelButtonTouched(_ sender: UIButtonComponent) {
        showCancelAlert()
    }

}

extension EmailVerificationViewController: TrackableScreen {
    public var screenName: String {
        return "LoginFlow/EmailVerification"
    }
}

extension EmailInputView: EmailInput {
    var email: String? {
        return textField.text
    }
}
