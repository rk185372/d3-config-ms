//
//  ChallengeDeviceUUIDItem.swift
//  Authentication
//
//  Created by Branden Smith on 8/5/19.
//

import Foundation
import Wrap

struct ChallengeDeviceUUIDItem: ChallengeItem {
    let challengeName = "DEVICE_UUID"
    let identifier = "DEVICE_UUID"
    let uuid: String
    let tabIndex: Int? = nil
}

extension ChallengeDeviceUUIDItem: Validatable {
    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}

extension ChallengeDeviceUUIDItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return [
            "identifier": identifier,
            "value": uuid
        ]
    }
}
