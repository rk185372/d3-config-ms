//
//  DepositAccountListResponse.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/13/18.
//

import Foundation
import D3Accounts

public struct DepositAccountListResponse: Codable {
    let tosRequired: Bool
    let blacklisted: Bool
    let userAccounts: [DepositAccount]
    let displayMessages: [String]
    let sessionId: String?
    let accountKeys: [String]?
}
