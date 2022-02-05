//
//  ChallengeReCaptchaItem.swift
//  Authentication
//
//  Created by Branden Smith on 7/25/19.
//

import Foundation

struct ChallengeReCaptchaItem: ChallengeItem {
    let identifier: String = "Recaptcha"
    let challengeName: String = "Recaptcha"
    let value: String
    var tabIndex: Int?

    init(token: String) {
        self.value = token
    }

    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}
