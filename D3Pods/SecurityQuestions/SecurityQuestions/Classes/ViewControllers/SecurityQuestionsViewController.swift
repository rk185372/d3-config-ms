//
//  SecurityQuestionsViewController.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/4/18.
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

public final class SecurityQuestionsViewController: AuthGenericViewController {
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var titleLabelView: UIView!
    @IBOutlet var patternDescriptionLabel: UILabelComponent!
    @IBOutlet var submitButton: UIButtonComponent!
    @IBOutlet var cancelButton: UIButtonComponent!
    @IBOutlet var loadingView: UIView!

    private let serviceItem: SecurityQuestionsService
    private let companyAttributesHolder: CompanyAttributesHolder
    private let postAuthFlowController: PostAuthFlowController

    private var presenters: [SecurityQuestionPresenter] = []

    private var questionMinLength: Int {
        return companyAttributesHolder
            .companyAttributes
            .value?
            .intValue(forKey: "consumerAuthentication.security.answer.length.min") ?? 1
    }

    private var questionMaxLength: Int {
        return companyAttributesHolder
            .companyAttributes
            .value?
            .intValue(forKey: "consumerAuthentication.security.answer.length.max") ?? 256
    }

    private var questionRegexValidation: String {
        return companyAttributesHolder
            .companyAttributes
            .value?
            .stringValue(forKey: "consumerAuthentication.security.answer.pattern") ?? ".*"
    }

    init(serviceItem: SecurityQuestionsService,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         companyAttributesHolder: CompanyAttributesHolder,
         postAuthFlowController: PostAuthFlowController) {
        self.serviceItem = serviceItem
        self.companyAttributesHolder = companyAttributesHolder
        self.postAuthFlowController = postAuthFlowController

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        addSecurityQuestionsSetupView(to: containerView)
        addLoadingView(to: self.contentStackView)
        addCancelAndSubmitButtons(to: buttonsStackView)
        configurePatternDescription()

        getSecurityQuestions()
    }

    private func addSecurityQuestionsSetupView(to container: UIView) {
        let securityQuestionsSetupView = SecurityQuestionsBundle
            .bundle
            .loadNibNamed("SecurityQuestionsSetupView", owner: self, options: [:])?
            .first as! UIView

        container.addSubview(securityQuestionsSetupView)

        securityQuestionsSetupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addLoadingView(to stackView: UIStackView) {
        loadingView.subviews.forEach { view in
            if let shimmerView = view as? FBShimmeringView {
                shimmerView.contentView = shimmerView.subviews.first
                shimmerView.isShimmering = true
            }
        }

        stackView.addArrangedSubview(loadingView)
    }

    private func removeLoadingView(from stackView: UIStackView) {
        loadingView.removeFromSuperview()
    }

    private func addCancelAndSubmitButtons(to stackView: UIStackView) {
        stackView.addArrangedSubview(submitButton)
        stackView.addArrangedSubview(cancelButton)
    }

    private func configurePatternDescription() {
        let parameterMap: [AnyHashable: Any] = [
            "minLength": questionMinLength,
            "maxLength": questionMaxLength
        ]

        patternDescriptionLabel.text = l10nProvider.localize(
            "credentials.security-question.pattern-description",
            parameterMap: parameterMap
        )
    }

    private func getSecurityQuestions() {
        serviceItem
            .getSecurityQuestions()
            .subscribe(onSuccess: { [unowned self] questions in
                self.removeLoadingView(from: self.contentStackView)
                self.submitButton.isHidden.toggle()
                self.cancelButton.isHidden.toggle()
                self.updatePresenters(with: questions)
                self.contentStackView.addArrangedSubview(self.titleLabelView)
                self.addQuestions(from: self.presenters, to: self.contentStackView)
                self.contentStackView.addArrangedSubview(self.patternDescriptionLabel)
                }, onError: { [unowned self] _ in
                    self.showQuestionLoadErrorWithRetry()
            })
            .disposed(by: bag)
    }

    private func updatePresenters(with questions: [SecurityQuestion]) {
        presenters = questions.map {
            let view = getSecurityQuestionView()
            let validators = getValidators()

            return SecurityQuestionPresenter(
                question: $0,
                view: view,
                l10nProvider: self.l10nProvider,
                validators: validators,
                delegate: self
            )
        }
    }

    private func getSecurityQuestionView() -> SecurityQuestionView {
        return SecurityQuestionsBundle
            .bundle
            .loadNibNamed("SecurityQuestionView", owner: nil, options: [:])?
            .first as! SecurityQuestionView
    }

    private func getValidators() -> [QuestionResponseValidator] {
        return [
            QuestionLengthValidator(
                minLength: self.questionMinLength,
                maxLength: self.questionMaxLength,
                emptyErrorMessage: self.l10nProvider.localize("credentials.security-question.answer.required"),
                minLengthError: self.l10nProvider.localize(
                    "credentials.security-question.validate.min",
                    parameterMap: ["minLength": self.questionMinLength]
                ),
                maxLengthError: self.l10nProvider.localize(
                    "credentials.security-question.validate.max",
                    parameterMap: ["maxLength": self.questionMaxLength]
                )
            ),
            QuestionRegexValidator(
                pattern: self.questionRegexValidation,
                errorMessage: self.l10nProvider.localize("banking.security.questionAnswerPattern")
            )
        ]
    }

    private func addQuestions(from presenters: [SecurityQuestionPresenter], to stackView: UIStackView) {
        presenters.forEach {
            self.contentStackView.addArrangedSubview($0.view)
        }
    }

    private func handleSubmit() {
        beginLoading(fromButton: submitButton)
        let questions = presenters.map { $0.question.dictionary() }

        serviceItem
            .postSecurityQuestions(questions: questions)
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

        log.debug("Handling Submit")
    }

    private func showCancelAlert() {
        let alert = UIAlertController(
            title: l10nProvider.localize("alert.standard.title"),
            message: l10nProvider.localize("credentials.mfa-enroll.text"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("credentials.mfa-enroll.btn.no"), style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("credentials.mfa-enroll.btn.yes"), style: .default) { _ in
                NotificationCenter.default.post(Notification(name: .loggedOut))
            }
        )

        present(alert, animated: true, completion: nil)
    }

    private func showQuestionLoadErrorWithRetry() {
        let alert = UIAlertController(
            title: l10nProvider.localize("app.error.generic.title"),
            message: l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.generic.retry"), style: .default) { _ in
                self.getSecurityQuestions()
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

extension SecurityQuestionsViewController: TrackableScreen {
    public var screenName: String {
        return "LoginFlow/SetupSecurityQuestions"
    }
}

extension SecurityQuestionsViewController: SecurityQuestionPresenterDelegate {
    func questionTapped(for presenter: SecurityQuestionPresenter) {
        let questionSelectionVC = QuestionSelectionViewController(
            componentSytleProvider: componentStyleProvider,
            l10nProvider: l10nProvider,
            questions: presenter.getQuestions()
        ) { selection in
            presenter.updateQuestion(with: selection)
        }
        
        present(questionSelectionVC, animated: true)
    }
}
