//
//  TransactionsServiceItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/18/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Network
import RxSwift

public final class TransactionsServiceItem: TransactionsService {

    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func getTransactions(accountID: Int) -> Single<TransactionResponse> {
        return client.request(API.Transactions.transactions(accountId: accountID))
    }
}
