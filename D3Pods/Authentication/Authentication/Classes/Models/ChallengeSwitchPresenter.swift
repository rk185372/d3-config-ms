//
//  ChallengeCheckboxPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/3/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import ComponentKit
import Foundation
import UITableViewPresentation
import ViewPresentable

protocol ChallengeCheckboxPresenterDelegate: class {
    func checkboxChanged(challengeCheckboxItem: ChallengeCheckboxItem, checkbox: UICheckboxComponent)
    func openSavedUserNamesList()
}

final class ChallengeCheckboxPresenter: ViewPresentable {
    let challenge: ChallengeCheckboxItem
    private let persistenceHelper: ChallengePersistenceHelper
    
    weak var delegate: ChallengeCheckboxPresenterDelegate?
    weak var view: ChallengeCheckboxView?
    
    init(challenge: ChallengeCheckboxItem, persistenceHelper: ChallengePersistenceHelper) {
        self.challenge = challenge
        self.persistenceHelper = persistenceHelper
    }
    
    func createView() -> ChallengeCheckboxView {
        return AuthenticationBundle.bundle.loadNibNamed("ChallengeCheckboxView", owner: nil, options: nil)!.first as! ChallengeCheckboxView
    }
    
    func configure(view: ChallengeCheckboxView) {
        self.view = view

        view.label.text = challenge.title
        view.accessibilityLabel = "\(challenge.title ?? "") checkbox"
        view.accessibilityIdentifier = "\(challenge.title ?? "") checkbox"
        view.label.isUserInteractionEnabled = true
        view.label.gestureRecognizers?.forEach({ view.label.removeGestureRecognizer($0) })
        view.label.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(labelTouched(_:)))
        )

        view.checkbox.checkState = challenge.value ? .checked : .unchecked
        view.checkbox.isAccessibilityElement = true
        view.checkbox.removeTarget(nil, action: #selector(checkboxChanged(sender:)), for: .valueChanged)
        view.checkbox.addTarget(self, action: #selector(checkboxChanged(sender:)), for: .valueChanged)
        view.maxCheckInfoBtn.addTarget(self, action: #selector(displayMaxSavedUserInfo), for: .touchUpInside)
        view.maxCheckInfoBtn.isHidden = false
        view.checkbox.isHidden = true
        if !persistenceHelper.savedUserLimitReached {
            view.maxCheckInfoBtn.isHidden = true
            view.checkbox.isHidden = false
        }

        updateAccessibilityValue()
    }

    @objc private func displayMaxSavedUserInfo(_ sender: UIButton) {
        NotificationCenter.default.post(name: .displayMaxSavedUserAlert, object: nil)
    }
    
    @objc private func labelTouched(_ sender: UILabelComponent) {
        view?.checkbox?.setCheckState((challenge.value) ? .unchecked : .checked, animated: true)
        challenge.value.toggle()
        updateAccessibilityValue()
    }
    
    @objc private func checkboxChanged(sender: UICheckboxComponent) {
        challenge.value = sender.checkState == .checked ? true : false
        delegate?.checkboxChanged(challengeCheckboxItem: challenge, checkbox: sender)
        updateAccessibilityValue()
    }

    private func updateAccessibilityValue() {
        view?.accessibilityValue = challenge.value ? "checked" : "unchecked"
    }
}

extension ChallengeCheckboxPresenter: Equatable {
    static func ==(lhs: ChallengeCheckboxPresenter, rhs: ChallengeCheckboxPresenter) -> Bool {
        guard lhs.challenge == rhs.challenge else { return false }
        
        return true
    }
}
