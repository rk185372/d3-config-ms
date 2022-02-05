//
//  AccountSection.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 10/17/19.
//

import D3Accounts
import Foundation

struct AccountSection: Codable {
    public let name: String
    public let items: [AccountListItem]
}
