//
//  ChallengeHelper.swift
//  Authentication
//
//  Created by Branden Smith on 8/22/18.
//

import Foundation
import ViewPresentable

final class ChallengeHelper {
    init() {}

    func hasValidationErrors(in challengeItems: [ChallengeItem]) -> Bool {
        var hasErrors = false

        for item in challengeItems {
            let status = (item as Validatable).validate(type: .form(items: challengeItems))

            if case ValidationStatus.error = status {
                hasErrors = true
            }
        }

        return hasErrors
    }

    func reconfigureView(forPresenter presenter: AnyViewPresentable,
                         inPresenters challengeItemPresenters: [AnyViewPresentable],
                         withStackView stackView: UIStackView) {
        guard let index = challengeItemPresenters.firstIndex(of: presenter) else { return }
        presenter.configure(view: stackView.subviews[index])
    }

    func reconfigureViews(inPresenters challengeItemPresenters: [AnyViewPresentable], withStackView stackView: UIStackView) {
        challengeItemPresenters.forEach {
            reconfigureView(forPresenter: $0, inPresenters: challengeItemPresenters, withStackView: stackView)
        }
    }
}
