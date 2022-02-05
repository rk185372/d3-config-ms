//
//  ChallengeAction.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/5/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import ComponentKit
import Wrap

final class ChallengeAction: Decodable {
    enum ActionType: String, Decodable {
        case submit = "SUBMIT"
        case cancel = "CANCEL"
        case back = "BACK"
        case oobResend = "OOB_RESEND"
        case generic = "GENERIC"
        case cancelAbort = "CANCEL_ABORT"
        
        var style: ButtonStyleKey {
            if case .submit = self {
                return .buttonCta
            } else {
                return .buttonOutlineOnDefault
            }
        }
    }
    
    let identifier: String
    let title: String
    let type: ActionType
    let tabIndex: Int?
    let challenge: String?
    let dialog: Dialog?
    let inAppRatingKey: String?
    
    enum CodingKeys: CodingKey {
        case identifier
        case title
        case type
        case tabIndex
        case challenge
        case dialog
        case inAppRatingKey
    }
    
    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(ActionType.self, forKey: .type)
        tabIndex = try? container.decodeIfPresent(Int.self, forKey: .tabIndex)
        challenge = try? container.decode(String.self, forKey: .challenge)
        dialog = try? container.decode(Dialog.self, forKey: .dialog)
        inAppRatingKey = try? container.decodeIfPresent(String.self, forKey: .inAppRatingKey)
    }
    
    init(identifier: String,
         title: String,
         type: ActionType,
         tabIndex: Int?,
         challenge: String?,
         dialog: Dialog?,
         inAppRatingKey: String? = nil) {
        self.identifier = identifier
        self.title = title
        self.type = type
        self.tabIndex = tabIndex
        self.challenge = challenge
        self.dialog = dialog
        self.inAppRatingKey = inAppRatingKey
    }
}

extension ChallengeAction: Equatable {
    static func ==(lhs: ChallengeAction, rhs: ChallengeAction) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.type == rhs.type else { return false }
        
        return true
    }
}
