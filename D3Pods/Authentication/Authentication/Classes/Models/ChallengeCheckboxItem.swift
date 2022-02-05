//
//  ChallengeCheckboxItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/5/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Wrap

final class ChallengeCheckboxItem: ChallengeItem {
    let identifier: String
    let challengeName: String
    let tabIndex: Int?
    let title: String?
    let description: String?
    var value: Bool

    enum CodingKeys: String, CodingKey {
        case identifier
        case challengeName
        case tabIndex
        case title
        case validators
        case description
        case value
    }

    init(identifier: String, challengeName: String, title: String?, description: String?, value: Bool) {
        self.identifier = identifier
        self.challengeName = challengeName
        self.tabIndex = nil
        self.title = title
        self.description = description
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        challengeName = try container.decode(String.self, forKey: .challengeName)
        tabIndex = try container.decodeIfPresent(Int.self, forKey: .tabIndex)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        value = try container.decode(Bool.self, forKey: .value)
    }

    func validate(type: ValidationType) -> ValidationStatus {
        return .noErrors
    }
}

extension ChallengeCheckboxItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        let wrappedDictionary: WrappedDictionary = [
            "identifier": identifier,
            "value": value
        ]
        
        return wrappedDictionary
    }
}

extension ChallengeCheckboxItem: Equatable {
    static func ==(lhs: ChallengeCheckboxItem, rhs: ChallengeCheckboxItem) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.challengeName == rhs.challengeName else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.description == rhs.description else { return false }
        guard lhs.value == rhs.value else { return false }
        
        return true
    }
}
