//
//  ChallengeActionPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/3/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import ComponentKit
import ViewPresentable

protocol ChallengeActionPresenterDelegate: class {
    func buttonPressed(challengeButtonItem: ChallengeAction, button: UIButtonComponent, reCaptchaToken token: String?)
}

final class ChallengeActionPresenter: ViewPresentable {
    let challenge: ChallengeAction
    let componentStyleProvider: ComponentStyleProvider
    
    weak var delegate: ChallengeActionPresenterDelegate?
    weak var view: ChallengeButtonView?
    
    init(challenge: ChallengeAction,
         componentStyleProvider: ComponentStyleProvider,
         delegate: ChallengeActionPresenterDelegate? = nil) {
        self.challenge = challenge
        self.componentStyleProvider = componentStyleProvider
        self.delegate = delegate
    }
    
    func createView() -> ChallengeButtonView {
        return AuthenticationBundle.bundle.loadNibNamed("ChallengeButtonView", owner: nil, options: nil)!.first as! ChallengeButtonView
    }
    
    func configure(view: ChallengeButtonView) {
        self.view = view
        
        view.button.setTitle(challenge.title, for: .normal)
        
        view.button.removeTarget(nil, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        view.button.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)

        view.button.configureComponent(withStyle: challenge.type.style)
    }
    
    @objc private func buttonPressed(button: UIButtonComponent) {
        delegate?.buttonPressed(challengeButtonItem: challenge, button: button, reCaptchaToken: nil)
    }
}

extension ChallengeActionPresenter: Equatable {
    static func ==(lhs: ChallengeActionPresenter, rhs: ChallengeActionPresenter) -> Bool {
        guard lhs.challenge == rhs.challenge else { return false }
        
        return true
    }
}
