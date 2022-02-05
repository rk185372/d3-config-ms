//
//  ChallengeResponse.swift
//  Authentication
//
//  Created by Chris Carranza on 6/21/18.
//

import Foundation
import Utilities
import ComponentKit

public final class ChallengeResponse: Decodable {
    let type: String?
    let titles: [ChallengeTitle]
    let items: [ChallengeItem]
    let actions: [ChallengeAction]
    let isAuthenticated: Bool
    let token: String?
    let previousItems: [[String: Any]]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case titles
        case items
        case actions
        case isAuthenticated
        case token
        case previousItems
    }

    init(type: String?,
         titles: [ChallengeTitle],
         items: [ChallengeItem],
         actions: [ChallengeAction],
         isAuthenticated: Bool,
         token: String?,
         previousItems: [[String: Any]]?) {
        self.type = type
        self.titles = titles
        self.items = items
        self.actions = actions
        self.isAuthenticated = isAuthenticated
        self.token = token
        self.previousItems = previousItems
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let descriptors = try container.decode([ChallengeItemDescriptor].self, forKey: .items)
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
        titles = try container.decodeIfPresent([ChallengeTitle].self, forKey: .titles) ?? []
        items = descriptors.map { $0.challengeItem }
        actions = try container.decode([ChallengeAction].self, forKey: .actions)
        isAuthenticated = try container.decode(Bool.self, forKey: .isAuthenticated)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        previousItems = try container.decodeIfPresent([Any].self, forKey: .previousItems) as? [[String: Any]] ?? []
    }

    public func challengeResponseStrippingNonPresentableItems() -> ChallengeResponse {
        return ChallengeResponse(
            type: self.type,
            titles: self.titles,
            items: self.items.filter({ item in
                !(item is ChallengeDeviceTokenItem) && !(item is ChallengeDeviceUUIDItem)
            }),
            actions: self.actions,
            isAuthenticated: self.isAuthenticated,
            token: self.token,
            previousItems: self.previousItems
        )
    }
}

extension ChallengeResponse {
    private struct ChallengeItemDescriptor: Decodable {
        enum ChallengeItemType: String, Codable {
            case tabSegment = "TAB_SEGMENT"
            case textInput = "TEXT_INPUT"
            case checkbox = "CHECKBOX"
            case rememberDevice = "REMEMBER_DEVICE"
            case radioButton = "RADIO_BUTTON"
            case saveUsername = "SAVE_USERNAME"
            case businessTooltip = "BUSINESS_TOOLTIP"
            case newQuestion = "NEW_QUESTION"
            case deviceToken = "DEVICE_TOKEN"
            case linkButton = "LINK_BUTTONS"
            
            func decode(decoder: Decoder, codingKeys: ChallengeItemDescriptor.CodingKeys.Type) throws -> ChallengeItem {
                let container = try decoder.container(keyedBy: codingKeys.self)
                
                switch self {
                case .textInput:
                    return try container.decode(ChallengeTextInputItem.self, forKey: .data)
                case .tabSegment:
                    return try container.decode(ChallengeTabSegmentItems.self, forKey: .data)
                case .checkbox, .rememberDevice, .saveUsername:
                    return try container.decode(ChallengeCheckboxItem.self, forKey: .data)
                case .radioButton:
                    return try container.decode(ChallengeRadioButtonItem.self, forKey: .data)
                case .newQuestion:
                    return try container.decode(ChallengeNewQuestionItem.self, forKey: .data)
                case .deviceToken:
                    return try container.decode(ChallengeDeviceTokenItem.self, forKey: .data)
                case .linkButton:
                    return try container.decode(ChallengeLinkButtonItems.self, forKey: .data)
                case .businessTooltip:
                    return try container.decode(ChallengeBusinessToolTipItems.self , forKey: .data)
                }
            }
        }
        
        let type: ChallengeItemType
        let challengeItem: ChallengeItem
        
        enum CodingKeys: String, CodingKey {
            case type
            case data
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(ChallengeItemType.self, forKey: .type)
            challengeItem = try type.decode(decoder: decoder, codingKeys: CodingKeys.self)
        }
    }
}
