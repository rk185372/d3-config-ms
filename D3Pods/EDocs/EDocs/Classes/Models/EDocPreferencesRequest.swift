//
//  EDocPreferencesRequest.swift
//  EDocs
//
//  Created by Branden Smith on 12/19/19.
//

import Foundation

public struct UpdateDeliverySettings: Codable {
    let electronicDocumentType: String
    let taxPreference: String?
    let accounts: [EDocsPromptAccount]
}

public extension UpdateDeliverySettings {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "electronicDocumentType": electronicDocumentType,
            "accounts": accounts.map({ $0.toDictionary() })
        ]

        if let taxPreference = taxPreference {
            dict["taxPreference"] = taxPreference
        }

        return dict
    }
}

extension EDocsPromptAccount {
    func toDictionary() -> [String: Any] {
        return [
            "userAccountId": userAccountId,
            "preference": "ELECTRONIC"
        ]
    }
}
