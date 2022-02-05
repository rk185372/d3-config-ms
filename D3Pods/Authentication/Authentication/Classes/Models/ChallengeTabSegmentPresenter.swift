//
//  ChallengeTabSegmentPresenter.swift
//  Authentication
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 2/4/21.
//

import Foundation
import ViewPresentable
import RxSwift
import Localization

protocol ChallengeTabSegmentPresenterdelegate: class {
    func segmentValueChanged(challengeTabSegmentItems: ChallengeTabSegmentItems, tabsegment: UISegmentedControl)
}

final class ChallengeTabSegmentPresenter: ViewPresentable {
    
    let challenge: ChallengeTabSegmentItems
    private let bag = DisposeBag()
    weak var delegate: ChallengeTabSegmentPresenterdelegate?
    private let selectedTabSegmentIndex: Int
    private let l10nProvider: L10nProvider
    
    init(challenge: ChallengeTabSegmentItems,
         selectedTabSegmentIndex: Int,
         l10nProvider: L10nProvider) {
        self.challenge = challenge
        self.selectedTabSegmentIndex = selectedTabSegmentIndex
        self.l10nProvider = l10nProvider
    }
    
    func createView() -> ChallengeTabSegmentView {
        return AuthenticationBundle.bundle.loadNibNamed(
            "ChallengeTabSegmentView",
            owner: nil,
            options: nil
        )!.first as! ChallengeTabSegmentView
    }
    
    func configure(view: ChallengeTabSegmentView) {
        view.tabSegmentControl?.setTitle(l10nProvider.localize("login.personal.toggle.title"), forSegmentAt: 0)
        view.tabSegmentControl?.setTitle(l10nProvider.localize("login.business.toggle.title"), forSegmentAt: 1)
        view.tabSegmentControl?.selectedSegmentIndex = self.selectedTabSegmentIndex
        view.tabSegmentControl.addTarget(self, action: #selector(segmentValueChanged(_ :)), for: .valueChanged )
    }
    
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        delegate?.segmentValueChanged(challengeTabSegmentItems: challenge, tabsegment: sender)
    }
}

extension ChallengeTabSegmentPresenter: Equatable {
    static func == (lhs: ChallengeTabSegmentPresenter, rhs: ChallengeTabSegmentPresenter) -> Bool {
        guard lhs.selectedTabSegmentIndex == rhs.selectedTabSegmentIndex else { return false }
        return true
    }
}
