//
//  EDocsPromptAccount.swift
//  EDocs
//
//  Created by Andrew Watt on 8/23/18.
//

import Foundation

public struct EDocsPromptAccount: Codable, Equatable {
    public let userAccountId: Int
    public let accountNumber: String
    public let accountName: String
}
