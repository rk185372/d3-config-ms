//
//  ChallengeNewQuestionItemPresenter.swift
//  Authentication
//
//  Created by Branden Smith on 7/20/18.
//

import Foundation
import UITableViewPresentation
import Utilities
import ComponentKit
import ViewPresentable

protocol ChallengeNewQuestionPresenterDelegate: class {
    func newQuestionPresenter(_: ChallengeNewQuestionItemPresenter, requestedQuestionChangeForChallenge challenge: ChallengeNewQuestionItem)
    func editingEnded(forTextField textField: UITextField, inPresenter presenter: ChallengeNewQuestionItemPresenter)
}

final class ChallengeNewQuestionItemPresenter: ViewPresentable {
    let challenge: ChallengeNewQuestionItem
    let componentStyleProvider: ComponentStyleProvider
    let textFieldManager = TextFieldManager()

    weak var delegate: ChallengeNewQuestionPresenterDelegate?

    init(challenge: ChallengeNewQuestionItem, componentStyleProvider: ComponentStyleProvider) {
        self.challenge = challenge
        self.componentStyleProvider = componentStyleProvider
        textFieldManager.delegate = self
    }

    func createView() -> ChallengeNewQuestionView {
        return AuthenticationBundle
            .bundle
            .loadNibNamed("ChallengeNewQuestionView", owner: nil, options: nil)!.first as! ChallengeNewQuestionView
    }

    func configure(view: ChallengeNewQuestionView) {
        view.textField.delegate = textFieldManager
        view.label.text = challenge.selectedQuestion ?? ""
        view.label.gestureRecognizers?.forEach {
            view.label.removeGestureRecognizer($0)
        }

        if let errorMessage = challenge.errors.first {
            view.errorLabel.text = errorMessage
            view.errorLabel.isHidden = false
        } else {
            view.errorLabel.text = ""
            view.errorLabel.isHidden = true
        }

        view.textField.removeTarget(nil, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        view.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTouched(_:)))
        view.label.addGestureRecognizer(gestureRecognizer)
        
        view.rightarrowButton.addTarget(self, action: #selector(labelTouched(_:)), for: .touchUpInside)

        view.textField?.configureComponent(withStyle: .textInputOnDefault)
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        challenge.value = textField.text
    }

    @objc private func labelTouched(_ label: UILabel) {
        delegate?.newQuestionPresenter(self, requestedQuestionChangeForChallenge: challenge)
    }
}

extension ChallengeNewQuestionItemPresenter: Equatable {
    static func ==(_ lhs: ChallengeNewQuestionItemPresenter, _ rhs: ChallengeNewQuestionItemPresenter) -> Bool {
        return lhs.challenge == rhs.challenge
    }
}

extension ChallengeNewQuestionItemPresenter: TextFieldManagerDelegate {
    func editingEnded(forTextField textField: UITextField, managedBy manager: TextFieldManager) {
        delegate?.editingEnded(forTextField: textField, inPresenter: self)
    }
}
