//
//  ChallengeBusinessToolTipItems.swift
//  Accounts-iOS
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 2/3/21.
//

import Foundation
import Wrap

final class ChallengeBusinessToolTipItems: ChallengeItem {
    struct ChallengeBusinessToolTipItem: Decodable {
        let identifier: String
        let challengeName: String
        let tabIndex: Int?
        let titles: [Titles]?
    }
    
    struct Titles: Decodable {
        let type: String
        let text: String
    }
    
    let identifier: String
    let challengeName: String
    var tabIndex: Int?
    let titles: [Titles]

    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}
