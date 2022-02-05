//
//  API+Transactions.swift
//  Accounts
//
//  Created by Chris Carranza on 1/16/18.
//

import Foundation
import Network

extension API {
    enum Transactions {
        static func transactions(accountId: Int) -> Endpoint<TransactionResponse> {
            return Endpoint<TransactionResponse>(path: "v4/accounts/\(accountId)/transactions")
        }
    }
}
