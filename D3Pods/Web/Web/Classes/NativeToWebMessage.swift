//
//  NativeToWebMessage.swift
//  Web
//
//  Created by Andrew Watt on 10/10/18.
//

import Foundation
import Session

enum NativeToWebMessage {
    private struct UpdateUserProfileMessage: Encodable {
        let type = "updateUserProfile"
        let profile: UserProfile
        let index: Int
    }
    
    private struct SelectProfileMessage: Encodable {
        let type = "selectProfile"
        let index: Int
    }
    
    private struct SectionRequiresUpdateMessage: Encodable {
        let type = "sectionRequiresUpdate"
        let section: String
    }

    private struct FeatureTourCompleted: Encodable {
        let type = "featureTourCompleted"
    }
    
    case updateUserProfile(userProfile: UserProfile, index: Int)
    case selectProfile(index: Int)
    case sectionRequiresUpdate(section: String)
    case featureTourCompleted
    
    func encodedJson() throws -> String {
        let encoder = JSONEncoder()
        let data: Data = try messageObject.encode(with: encoder)
        return try String(jsonData: data)
    }
    
    private var messageObject: Encodable {
        switch self {
        case let .updateUserProfile(userProfile, index):
            return UpdateUserProfileMessage(profile: userProfile, index: index)
        case let .selectProfile(index):
            return SelectProfileMessage(index: index)
        case let .sectionRequiresUpdate(section: section):
            return SectionRequiresUpdateMessage(section: section)
        case .featureTourCompleted:
            return FeatureTourCompleted()
        }
    }
}

extension NativeToWebMessage: CustomStringConvertible {
    var description: String {
        switch self {
        case .updateUserProfile: return "updateUserProfile"
        case .selectProfile: return "selectUserProfile"
        case .sectionRequiresUpdate: return "sectionRequiresUpdate"
        case .featureTourCompleted: return "featureTourCompleted"
        }
    }
}
