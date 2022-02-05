//
//  ChallengeTabSegmentItems.swift
//  Accounts-iOS
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 2/3/21.
//

import Foundation

final class ChallengeTabSegmentItems: ChallengeItem {

    let identifier: String
    let challengeName: String
    let tabIndex: Int?
    let segments: [String]

    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}
