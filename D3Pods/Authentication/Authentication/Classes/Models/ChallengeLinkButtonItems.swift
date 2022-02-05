//
//  ChallengeLinkButtonItems.swift
//  Authentication
//
//  Created by Elvin Bearden on 11/27/20.
//

import Foundation

final class ChallengeLinkButtonItems: ChallengeItem {
    struct ChallengeLinkButtonItem: Decodable {
        let title: String
        let url: URL?
        let buttonDialog: ChallengeButtonDialog?
    }
    let identifier: String
    let tabIndex: Int?
    let challengeName: String
    let buttons: [ChallengeLinkButtonItem]

    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}
