//
//  ChallengeDeviceTokenItem.swift
//  Authentication
//
//  Created by Branden Smith on 8/1/19.
//

import Foundation
import Wrap

struct ChallengeDeviceTokenItem: ChallengeItem {
    let identifier: String = "DEVICE_TOKEN"
    let challengeName: String = "DEVICE_TOKEN"
    let token: String
    let tabIndex: Int? = nil
}

extension ChallengeDeviceTokenItem: Validatable {
    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}

extension ChallengeDeviceTokenItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return [
            "identifier": identifier,
            "value": token
        ]
    }
}
