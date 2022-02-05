//
//  ChallengeRadioButtonItemPresenter.swift
//  Accounts
//
//  Created by Chris Carranza on 7/10/18.
//

import ComponentKit
import Foundation
import ViewPresentable

protocol ChallengeRadioButtonItemPresenterDelegate: class {
    func selectionChanged(presenter: ChallengeRadioButtonItemPresenter)
}

final class ChallengeRadioButtonItemPresenter: ViewPresentable {
    
    let challenge: ChallengeRadioButtonItem
    weak var delegate: ChallengeRadioButtonItemPresenterDelegate?
    
    private let presenters: [ChallengeRadioItemPresenter]
    private let componentStyleProvider: ComponentStyleProvider
    
    init(challenge: ChallengeRadioButtonItem, componentStyleProvider: ComponentStyleProvider) {
        self.challenge = challenge
        self.componentStyleProvider = componentStyleProvider
        presenters = challenge.items.map { ChallengeRadioItemPresenter(radioItem: $0, componentStyleProvider: componentStyleProvider) }
        presenters.forEach { $0.delegate = self }
    }
    
    func createView() -> ChallengeRadioGroupView {
        let view = AuthenticationBundle.bundle.loadNibNamed("ChallengeRadioGroupView",
                                                        owner: nil,
                                                        options: nil)!.first as! ChallengeRadioGroupView
        presenters.forEach { (presenter) in
            let radioButtonView = presenter.createView()
            view.stackView.addArrangedSubview(radioButtonView)
        }
        
        return view
    }
    
    func configure(view: ChallengeRadioGroupView) {
        for (index, view) in view.stackView.arrangedSubviews.enumerated() {
            presenters[index].configure(view: view as! ChallengeRadioButtonView)
        }
    }
    
    static func == (lhs: ChallengeRadioButtonItemPresenter, rhs: ChallengeRadioButtonItemPresenter) -> Bool {
        return lhs.challenge == rhs.challenge
    }
}

extension ChallengeRadioButtonItemPresenter: ChallengeRadioItemPresenterDelegate {
    func didPressRadioButton(presenter: ChallengeRadioItemPresenter) {
        if challenge.items.count > 1 {
            for item in presenters {
                if item == presenter {
                    item.radioItem.selected = true
                } else {
                    item.radioItem.selected = false
                }
            }
            
            delegate?.selectionChanged(presenter: self)
        }
    }
}
