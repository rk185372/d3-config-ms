//
//  ChallengeTextInputPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/3/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import ComponentKit
import DependencyContainerExtension
import RxSwift
import Utilities
import ViewPresentable

protocol ChallengeTextInputPresenterDelegate: class {
    func editingEnded(forTextField textField: UITextField, inPresenter presenter: ChallengeTextInputPresenter)
    func rightButtonPressed(button: UIButton, inPresenter presenter: ChallengeTextInputPresenter)
    func usernameButtonPressed()
}

final class ChallengeTextInputPresenter: ViewPresentable {
    let challenge: ChallengeTextInputItem
    let componentStyleProvider: ComponentStyleProvider
    let textFieldManager = TextFieldManager()
    let persistenceHelper: ChallengePersistenceHelper
    let isPersonalAccount: Bool

    private var lastAnnouncementSent: String = ""
    private let bag = DisposeBag()
    private let rightButton = UIButton(type: .custom)
    
    weak var delegate: ChallengeTextInputPresenterDelegate?
    
    init(challenge: ChallengeTextInputItem,
         componentStyleProvider: ComponentStyleProvider,
         persistenceHelper: ChallengePersistenceHelper) {
        self.challenge = challenge
        self.isPersonalAccount = challenge.tabIndex == 0
        self.componentStyleProvider = componentStyleProvider
        self.persistenceHelper = persistenceHelper
        textFieldManager.delegate = self

        // We are registering here so that we can retry if posting the announcement
        // fails.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(announcementFinished(_:)),
            name: UIAccessibility.announcementDidFinishNotification,
            object: nil
        )
    }
    
    func createView() -> ChallengeTextInputView {
        return AuthenticationBundle.bundle.loadNibNamed(
            "ChallengeTextInputView",
            owner: nil,
            options: nil
        )!.first as! ChallengeTextInputView
    }
    
    func configure(view: ChallengeTextInputView) {
        view.textField.placeholder = challenge.placeholder
        view.textField.isUserInteractionEnabled = challenge.isEditable
        view.textField.isSecureTextEntry = challenge.isSecure
        view.textField.delegate = textFieldManager
        view.textField.accessibilityIdentifier = "challenge-text-input-\(challenge.challengeName)"

        let shouldClearOnBeginEditing = (challenge.challengeName == ChallengeName.username.rawValue
                                            || challenge.challengeName == ChallengeName.business_username.rawValue)
            && challenge.maskedValue != nil
        view.textField.clearsOnBeginEditing = shouldClearOnBeginEditing

        if challenge.isSecure, rightButton.superview != view {
            rightButton.setImage(
                UIImage(named: "Eye_Off", in: AuthenticationBundle.bundle, compatibleWith: nil)!,
                for: .normal
            )
            rightButton.setImage(
                UIImage(named: "Eye", in: AuthenticationBundle.bundle, compatibleWith: nil)!,
                for: .selected
            )
            rightButton.tintColor = try! UIColor(rgba_throws: "#D5D5D5")
            rightButton.imageView?.contentMode = .scaleAspectFit
            rightButton.accessibilityIdentifier = "challenge-text-input-button-eye"

            view.addSubview(rightButton)
            rightButton.snp.makeConstraints { (make) in
                make.width.equalTo(25)
                make.height.lessThanOrEqualTo(22)
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
            }

            rightButton.rx.tap.bind {
                self.rightButton.isSelected.toggle()
                view.textField.isSecureTextEntry.toggle()
            }.disposed(by: bag)
        }

        if let masked = challenge.maskedValue {
            view.textField.text = masked
        } else {
            if challenge.challengeName == "username", let challengeUsername = challenge.displayText, !challengeUsername.isEmpty {
                view.textField.text = challengeUsername
                challenge.value = challengeUsername
            } else {
                view.textField.text = challenge.value
            }
        }

        if !challenge.errors.isEmpty {
            view.errorLabel.text = challenge.errors.first!
            view.errorLabel.isHidden = false

            if UIAccessibility.isVoiceOverRunning {
                // Posting this notification is not always guaranteed to succeed.
                // It may because voice over is already announcing something or reading
                // something when this notification is observed.
                // To get around this, we keep track of the last announcement we
                // posted and observerve on UIAccessibility.announcementDidFinishNotification
                // When this notification has processed, we will be observing the result with
                // announcementFinished(_:).
                lastAnnouncementSent = self.challenge.errors.first!
                UIAccessibility.post(notification: .announcement, argument: self.challenge.errors.first!)
            }
        } else {
            view.errorLabel.text = ""
            view.errorLabel.isHidden = true
        }
        if(challenge.button != nil || challenge.title != nil) {
            view.infoView.isHidden = false
        } else {
            view.infoView.isHidden = true
        }
        
        if (challenge.button != nil && challenge.challengeName == "business_username") {
            view.infoView.isHidden = false
            view.infoButton.isHidden = false
            view.infoButton.addTarget(self, action: #selector(rightButtonPressed(button:)), for: .touchUpInside)
            view.infoButton.accessibilityLabel = "\(challenge.button?.iconType ?? "") info"
            view.infoButton.accessibilityIdentifier = "challenge-text-input-infobutton-\(challenge.button?.iconType ?? "")"
            if !self.isPersonalAccount &&
                !persistenceHelper.savedUsernames(currentTabIndex: self.isPersonalAccount ? 0 : 1).isEmpty {
                view.infoView.isHidden = true
            }
        } else {
            view.infoButton.isHidden = true
            view.infoView.isHidden = true
        }
        
        if let title = challenge.title {
            view.infoView.isHidden = false
            view.titleLabel.isHidden = false
            view.titleLabel.text = title
            view.infoView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            view.titleLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        } else {
            view.titleLabel.isHidden = true
        }
        
        view.textField.removeTarget(nil, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        view.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        view.textField?.configureComponent(withStyle: .textInputOnLogin)

        if (challenge.challengeName == "username" || challenge.challengeName == "business_username" ),
            !persistenceHelper.savedUsernames(currentTabIndex: self.isPersonalAccount ? 0 : 1).isEmpty {
            view.textField.placeholder = nil
            view.titleLabel.isHidden = true
            view.button.isHidden = false
            view.button.accessibilityIdentifier = "username-view-button"
            view.button.rx.tap.bind {
                self.delegate?.usernameButtonPressed()
            }.disposed(by: bag)
        } else {
            view.button.isHidden = true
        }
    }

    /// This method is called as a result of observing the UIAccessibility.announcementDidFinishNotification
    /// When posting an announcement, the first try may fail. We observe finished announcements here and
    /// check to see if the announcement is the same as the one this object last posted and if it was
    /// successful or not. If not successful, and the announcement is the one we last posted we will make the
    /// post again. This is essentially a retry mechanism for an anoucement posted by this object that may have
    /// failed.
    ///
    /// - Parameter sender: Notification
    @objc func announcementFinished(_ sender: Notification) {
        guard let announcement = sender.userInfo![UIAccessibility.announcementStringValueUserInfoKey] as? String else { return }
        guard let success = sender.userInfo![UIAccessibility.announcementWasSuccessfulUserInfoKey] as? Bool else { return }

        if !success && announcement == lastAnnouncementSent {
            lastAnnouncementSent = self.challenge.errors.first!
            UIAccessibility.post(notification: .announcement, argument: self.challenge.errors.first!)
        }
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        challenge.maskedValue = nil
        challenge.value = textField.text
        textField.clearsOnBeginEditing = false
    }
    
    @objc private func rightButtonPressed(button: UIButton) {
        delegate?.rightButtonPressed(button: button, inPresenter: self)
    }
}

extension ChallengeTextInputPresenter: Equatable {
    static func ==(_ lhs: ChallengeTextInputPresenter, _ rhs: ChallengeTextInputPresenter) -> Bool {
        return lhs.challenge == rhs.challenge
    }
}

extension ChallengeTextInputPresenter: TextFieldManagerDelegate {
    func editingEnded(forTextField textField: UITextField, managedBy manager: TextFieldManager) {
        delegate?.editingEnded(forTextField: textField, inPresenter: self)
    }
}

extension UIButton {
    func constraintWith(identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first(where: {$0.identifier == identifier})
    }
}
