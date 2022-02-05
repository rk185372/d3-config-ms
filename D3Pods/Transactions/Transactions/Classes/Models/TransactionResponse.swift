//
//  TransactionResponse.swift
//  Accounts
//
//  Created by Chris Carranza on 7/12/17.
//

import Foundation

public struct TransactionResponse: Decodable {
    public let results: [Transaction]
}
