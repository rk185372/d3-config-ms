//
//  SnapshotServiceMock.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import QuickView
import Utilities
import Network

@testable import Accounts
@testable import Transactions
@testable import D3_N3xt

final class SnapshotServiceMock: SnapshotService {
    func transactions(withCompletion completion: @escaping (Result<[Transaction]>) -> Void) {
        completion(.failure(NSError()))
    }
    
    func getSnapshot(withCompletion completion: @escaping (Result<Snapshot>) -> Void) {
        completion(.success(Snapshot(accounts: accounts)))
    }

    let accounts: [Account] = [
        .init(
            id: 0,
            balance: "$0",
            availableBalance: "$0",
            name: "Johny's Checking 1",
            number: "•••••4321",
            type: .asset
        ),
        .init(
            id: 1,
            balance: "$1,000,000,000,000",
            availableBalance: "$1,000,000,000,000",
            name: "Johny's Savings 1",
            number: "•••••9876",
            type: .asset
        ),
        .init(
            id: 2,
            balance: "$200",
            availableBalance: "$200",
            name: "Johny's Savings That Has a Really Really Really Long Name",
            number: "•••••43",
            type: .asset
        ),
        .init(
            id: 3,
            balance: "$1,000,000,000,000",
            availableBalance: "$1,000,000,000,000",
            name: "Johny's Savings With Really Long Account Number And Balance",
            number: "••••••••••••••••••••432",
            type: .asset
        ),
        .init(
            id: 4,
            balance: "$2,450",
            availableBalance: "2,300",
            name: "Johny's Credit Card",
            number: "7654321",
            type: .liability
        ),
        .init(
            id: 5,
            balance: "$1,000,000",
            availableBalance: "$1",
            name: "Johny's Credit Card 2",
            number: "7654321",
            type: .liability
        )
    ]
}
