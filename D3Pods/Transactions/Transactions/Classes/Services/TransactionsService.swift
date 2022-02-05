//
//  TransactionsService.swift
//  Transactions
//
//  Created by Chris Carranza on 1/26/18.
//

import Foundation
import RxSwift

public protocol TransactionsService {
    func getTransactions(accountID: Int) -> Single<TransactionResponse>
}
