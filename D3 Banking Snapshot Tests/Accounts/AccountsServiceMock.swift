//
//  AccountsServiceMock.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/30/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Utilities
import Network

@testable import Accounts

final class AccountsServiceMock: AccountsService {
    func getAccounts(withCompletion completion: @escaping (Result<[Account]>) -> Void) {
        completion(.success(accounts))
    }

    let accounts: [Account] = [
        .init(
            id: 0,
            balance: "$0",
            availableBalance: "$0",
            name: "Johny's Checking",
            number: "1234567",
            type: .asset
        ),
        .init(
            id: 1,
            balance: "$1",
            availableBalance: "$1",
            name: "Johny's Savings",
            number: "7654321",
            type: .asset
        )
    ]
}
