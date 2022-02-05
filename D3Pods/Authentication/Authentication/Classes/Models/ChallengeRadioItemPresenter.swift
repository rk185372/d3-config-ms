//
//  ChallengeRadioItemPresenter.swift
//  Authentication
//
//  Created by Chris Carranza on 7/11/18.
//

import Foundation
import ComponentKit
import ViewPresentable
import Utilities

protocol ChallengeRadioItemPresenterDelegate: class {
    func didPressRadioButton(presenter: ChallengeRadioItemPresenter)
}

final class ChallengeRadioItemPresenter: ViewPresentable {
    
    let radioItem: ChallengeRadioButtonItem.RadioItem
    weak var delegate: ChallengeRadioItemPresenterDelegate?

    private let componentStyleProvider: ComponentStyleProvider
    
    init(radioItem: ChallengeRadioButtonItem.RadioItem, componentStyleProvider: ComponentStyleProvider) {
        self.radioItem = radioItem
        self.componentStyleProvider = componentStyleProvider
    }
    
    func createView() -> ChallengeRadioButtonView {
        return AuthenticationBundle.bundle.loadNibNamed("ChallengeRadioButtonView",
                                                        owner: nil,
                                                        options: nil)!.first as! ChallengeRadioButtonView
    }
    
    func configure(view: ChallengeRadioButtonView) {
        view.titleLabel.text = radioItem.title
        view.titleLabel.accessibilityLabel = radioItem.title
        view.subtitleLabel.text = radioItem.description
        view.subtitleLabel.accessibilityLabel = radioItem.description
        view.radioButtonComponent.isSelected = radioItem.selected
        view.radioButtonComponent.isEnabled = !radioItem.disabled
        view.radioButtonComponent.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        view.radioButtonComponent.isAccessibilityElement = true
        
        view.inputHolderView.isHidden = radioItem.input == nil || !radioItem.selected
        view.inputField.text = radioItem.inputValue
        view.inputField.placeholder = radioItem.input?.placeholder
        view.inputField.accessibilityIdentifier = radioItem.input?.placeholder
        view.inputFieldTooltipLabel.text = radioItem.input?.description
        
        view.inputField.removeTarget(nil, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        view.inputField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        view.radioButtonItemHolderView.accessibilityIdentifier = "radio-\(radioItem.title)"
        view.radioButtonItemHolderView.accessibilityLabel = radioItem.title
        view.radioButtonItemHolderView.gestureRecognizers?.forEach {
            view.radioButtonItemHolderView.removeGestureRecognizer($0)
        }

        view.radioButtonItemHolderView.accessibilityTraits = [.button]

        if radioItem.selected {
            view.radioButtonItemHolderView.accessibilityTraits.update(with: [.selected])
        } else {
            view.radioButtonItemHolderView.accessibilityTraits.remove([.selected])
        }

        // We are styling this manually here so that if the view is reused gray text
        // from a disabled state will not persist.
        let titleLabelStyle: LabelStyle = componentStyleProvider["h2OnDefault"]
        titleLabelStyle.style(component: view.titleLabel)

        let subtitleLabelStyle: LabelStyle = componentStyleProvider["h4OnDefault"]
        subtitleLabelStyle.style(component: view.subtitleLabel)

        if !radioItem.disabled {
            let gestureRecognizer = UITapGestureRecognizer()

            gestureRecognizer
                .rx
                .event
                .bind(onNext: { recognizer in
                    self.didPressButton(sender: recognizer)
                })
                .disposed(by: view.bag)

            view.radioButtonItemHolderView.addGestureRecognizer(gestureRecognizer)
            view.radioButtonItemHolderView.accessibilityTraits.remove([.notEnabled])
        } else {
            view.titleLabel.textColor = .gray
            view.subtitleLabel.textColor = .gray
            view.radioButtonItemHolderView.accessibilityTraits.update(with: [.notEnabled])
        }
        
        radioItem
            .input?
            .rx
            .errors
            .subscribe(onNext: { (errors) in
                view.errorLabelHolder.isHidden = errors.isEmpty
                if let firstError = errors.first {
                    view.errorLabel.text = firstError
                }
            })
            .disposed(by: view.bag)
    }
    
    @objc private func didPressButton(sender: Any) {
        delegate?.didPressRadioButton(presenter: self)
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        radioItem.inputValue = textField.text
    }
    
    static func == (lhs: ChallengeRadioItemPresenter, rhs: ChallengeRadioItemPresenter) -> Bool {
        return lhs.radioItem == rhs.radioItem
    }
}
