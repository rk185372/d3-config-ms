//
//  TransactionsServiceMock.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 1/26/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Utilities
import Network

@testable import Transactions

final class TransactionsServiceMock: TransactionsService {

    func getTransactions(accountId: Int) -> Promise<TransactionResponse> {
        fatalError()
    }
    
    func getTransactions(accountId: Int, withCompletion completion: @escaping (Network.Result<TransactionResponse>) -> Void) {
        fatalError()
    }
}
