//
//  Account.swift
//  Accounts
//
//  Created by Branden Smith on 3/15/18.
//

import Foundation
import Utilities

public struct Account: Codable, DisplayNameable {
    public let id: Int
    public let name: String
    public let nickname: String?
    public let accountNumber: String
    public let balance: Double
    public let currencyCode: String
    public let type: String
    public let accountProduct: String
    public let status: String
    public let lastSyncTime: String
    public let hidden: Bool
    public let excluded: Bool
    public let overdraft: AccountOverdraft
    public let capabilities: AccountPermissions
}
