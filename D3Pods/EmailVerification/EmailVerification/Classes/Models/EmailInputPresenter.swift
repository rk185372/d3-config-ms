//
//  EmailVerificationPresenter.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import ComponentKit
import Foundation
import Localization
import Logging
import UIKit
import Utilities

final class EmailInputPresenter {
    private(set) var email: String?
    private let title: String
    let view: EmailInputView
    
    private let l10nProvider: L10nProvider
    private let textFieldManager = TextFieldManager()
    private let validators: [EmailValidator]

    init(title: String,
         view: EmailInputView,
         l10nProvider: L10nProvider,
         validators: [EmailValidator]) {
        self.title = title
        self.l10nProvider = l10nProvider
        self.validators = validators
        self.view = view
        self.textFieldManager.delegate = self

        configureView()
    }

    private func configureView() {
        view.textField.placeholder = title
        view.errorLabel.isHidden = true
        view.textField.delegate = textFieldManager
        view.textField.removeTarget(nil, action: #selector(textFieldChanged(_:)), for: .allEvents)
        view.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
    }

    @objc private func textFieldChanged(_ textField: UITextField) {
        email = textField.text
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
            switch validator.validate(email) {
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

extension EmailInputPresenter: TextFieldManagerDelegate {
    func editingEnded(forTextField textField: UITextField, managedBy manager: TextFieldManager) {
        email = textField.text
        validate()
    }
}
