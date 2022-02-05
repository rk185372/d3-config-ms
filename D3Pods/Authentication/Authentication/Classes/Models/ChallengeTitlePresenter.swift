//
//  ChallengeTitlePresenter.swift
//  Authentication
//
//  Created by Chris Carranza on 7/9/18.
//

import Foundation
import ComponentKit
import ViewPresentable

final class ChallengeTitlePresenter: ViewPresentable {

    let challengeTitle: ChallengeTitle
    let componentStyleProvider: ComponentStyleProvider
    
    init(challengeTitle: ChallengeTitle,
         componentStyleProvider: ComponentStyleProvider) {
        self.challengeTitle = challengeTitle
        self.componentStyleProvider = componentStyleProvider
    }
    
    func createView() -> ChallengeTitleView {
        return AuthenticationBundle.bundle.loadNibNamed("ChallengeTitleView", owner: nil, options: nil)!.first as! ChallengeTitleView
    }
    
    func configure(view: ChallengeTitleView) {
        view.titleLabel.text = challengeTitle.text
        
        let style: AnyComponentStyle
        var isBold = false
        
        switch challengeTitle.titleType {
        case .major:
            style = componentStyleProvider[LabelStyleKey(size: .h1, color: .onDefault).keyValue]
            isBold = true
        default:
            style = componentStyleProvider[LabelStyleKey(size: .h3, color: .onDefault).keyValue]
        }

        if isBold {
            view.titleLabel.font = .boldSystemFont(ofSize: 10)
        }
        style.style(component: view.titleLabel as Any)

    }
    
    static func == (lhs: ChallengeTitlePresenter, rhs: ChallengeTitlePresenter) -> Bool {
        return lhs.challengeTitle == rhs.challengeTitle
    }
}
