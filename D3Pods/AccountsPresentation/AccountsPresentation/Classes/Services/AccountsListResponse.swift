//
//  AccountsListResponse.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 7/12/17.
//

import D3Accounts
import Foundation

struct AccountsListResponse: Codable {
    let accounts: [AccountListItem]
}

struct ConvertedAccountsListResponse: Codable {
    let accountSections: [AccountSection]
}
