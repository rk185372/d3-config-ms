//
//  EmailNotificationViewController.swift
//  EmailVerification
//
//  Created by Pablo Pellegrino on 11/10/2021.
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
import Utilities
import Analytics

public final class EmailNotificationViewController: AuthGenericViewController {
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var titleLabelView: UIView!
    @IBOutlet var emailLabelView: UIView!
    @IBOutlet var emailLabel: UILabelComponent!
    @IBOutlet var submitButton: UIButtonComponent!
    @IBOutlet var cancelButton: UIButtonComponent!
    
    private let serviceItem: EmailVerificationService
    private let postAuthFlowController: PostAuthFlowController
    private let currentEmail: String

    init(serviceItem: EmailVerificationService,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         postAuthFlowController: PostAuthFlowController,
         currentEmail: String) {
        self.serviceItem = serviceItem
        self.postAuthFlowController = postAuthFlowController
        self.currentEmail = currentEmail
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        addEmailNotificationView(to: containerView)
        addCancelAndSubmitButtons(to: buttonsStackView)
        setupContent()
    }

    private func addEmailNotificationView(to container: UIView) {
        let view = EmailVerificationBundle
            .bundle
            .loadNibNamed("EmailNotificationView", owner: self, options: [:])?
            .first as! UIView

        container.addSubview(view)

        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addCancelAndSubmitButtons(to stackView: UIStackView) {
        stackView.addArrangedSubview(submitButton)
        stackView.addArrangedSubview(cancelButton)
    }

    private func setupContent() {
        self.submitButton.isHidden.toggle()
        self.cancelButton.isHidden.toggle()
        self.contentStackView.addArrangedSubview(self.titleLabelView)
        self.contentStackView.addArrangedSubview(self.emailLabelView)
        
        emailLabel.text = l10nProvider.localize("primaryEmailVerification.maskedEmailLabel")
            + ": \n\(maskedEmail(currentEmail))"
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
        cleanEmailVerify()
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
        handleSubmit()
    }

    @IBAction func cancelButtonTouched(_ sender: UIButtonComponent) {
        showCancelAlert()
    }

}

extension EmailNotificationViewController: TrackableScreen {
    public var screenName: String {
        return "LoginFlow/EmailVerification"
    }
}

private extension EmailNotificationViewController {
    func maskedEmail(_ email: String) -> String {
        let domainIdx = email.firstIndex(of: "@") ?? email.endIndex
        let nonDomainString = email.prefix(email.distance(from: email.startIndex, to: domainIdx))
        guard 2 < nonDomainString.count else { return email }
        return nonDomainString.prefix(2)
            + "****"
            + nonDomainString.suffix(1)
            + String(email.suffix(email.count - nonDomainString.count))
    }
}
