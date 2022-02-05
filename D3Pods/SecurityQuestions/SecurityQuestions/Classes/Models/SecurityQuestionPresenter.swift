//
//  SecurityQuestionPresenter.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/5/18.
//

import ComponentKit
import Foundation
import Localization
import Logging
import UIKit
import Utilities

protocol SecurityQuestionPresenterDelegate: class {
    func questionTapped(for presenter: SecurityQuestionPresenter)
}

final class SecurityQuestionPresenter {
    let question: SecurityQuestion
    let view: SecurityQuestionView

    private let l10nProvider: L10nProvider
    private let textFieldManager = TextFieldManager()
    private let validators: [QuestionResponseValidator]

    private weak var delegate: SecurityQuestionPresenterDelegate?

    init(question: SecurityQuestion,
         view: SecurityQuestionView,
         l10nProvider: L10nProvider,
         validators: [QuestionResponseValidator],
         delegate: SecurityQuestionPresenterDelegate? = nil) {
        self.question = question
        self.delegate = delegate
        self.l10nProvider = l10nProvider
        self.validators = validators
        self.view = view
        self.textFieldManager.delegate = self

        configureView()
    }

    func updateQuestion(with newQuestion: String) {
        question.value = newQuestion
        view.questionLabel.text = question.value
    }

    func getQuestions() -> [String] {
        return question.choices
    }

    private func configureView() {
        view.errorLabel.isHidden = true
        view.disclosureIndicatorView.image = UIImage(named: "RightArrow")
        
        view.questionLabel.text = question.value
        view.questionStackView.gestureRecognizers?.forEach {
            view.questionStackView.removeGestureRecognizer($0)
        }

        view.questionStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(questionLabelTapped(_:)))
        )

        view.textField.delegate = textFieldManager
        view.textField.placeholder = l10nProvider.localize("credentials.security-question.answer.placeholder")
        view.textField.removeTarget(nil, action: #selector(textFieldChanged(_:)), for: .allEvents)
        view.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        addIsSecureEntryToggle(to: view.textField)
    }

    @objc private func textFieldChanged(_ textField: UITextField) {
        question.response = textField.text
    }

    @objc private func questionLabelTapped(_ label: UILabel) {
        delegate?.questionTapped(for: self)
    }

    @objc private func secureTextEntryButtonTouched(_ sender: UIButton) {
        view.textField.isSecureTextEntry.toggle()

        if view.textField.isSecureTextEntry {
            sender.setTitle(
                l10nProvider.localize("credentials.security-question.mobile.btn.show-answer"),
                for: .normal
            )
        } else {
            sender.setTitle(
                l10nProvider.localize("credentials.security-question.mobile.btn.hide-answer"),
                for: .normal
            )
        }
    }

    private func addIsSecureEntryToggle(to textField: UITextField) {
        textField.rightView = createShowAndHideButton()
        textField.rightViewMode = .whileEditing
        textField.clearButtonMode = .never
    }

    private func createShowAndHideButton() -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle(
            l10nProvider.localize("credentials.security-question.mobile.btn.show-answer"),
            for: .normal
        )
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(secureTextEntryButtonTouched(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 45, height: 28)
        addDivider(to: button)

        return button
    }

    private func addDivider(to button: UIButton) {
        let height = button.frame.height * 0.65
        let y = (button.frame.height - height) / 2
        let view = UIView(frame: CGRect(x: 0, y: y, width: 1, height: height))
        view.backgroundColor = .lightGray
        button.addSubview(view)
    }

    @discardableResult
    func validate() -> Bool {
        for validator in validators {
            switch validator.validate(question: question) {
            case .valid:
                view.errorLabel.isHidden = true
                continue
            case .invalid(let message):
                view.errorLabel.text = message
                view.errorLabel.isHidden = false
                return false
            }
        }

        return true
    }
}

extension SecurityQuestionPresenter: TextFieldManagerDelegate {
    func editingEnded(forTextField textField: UITextField, managedBy manager: TextFieldManager) {
        question.response = textField.text
        validate()
    }
}
