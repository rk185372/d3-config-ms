//
//  CardControlsResponse.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import D3Accounts
import Foundation

public struct CardControlsResponse: Codable {
    let userAccountId: Int
    let accountName: String
    let cards: [Card]
}
