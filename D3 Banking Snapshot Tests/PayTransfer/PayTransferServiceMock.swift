//
//  PayTransferServiceMock.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/30/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import MockData
import Network
import Utilities

@testable import D3_N3xt
@testable import PayTransfer

final class PayTransferServiceMock: PayTransferService {
    func getRecipients(withCompletion completion: @escaping (Result<RecipientResponse>) -> Void) {
        completion(.success(recipients))
    }

    func getAmounts(withCompletion completion: @escaping (Result<AmountResponse>) -> Void) {
        completion(.success(amounts))
    }

    func getDates(withCompletion completion: @escaping (Result<DateResponse>) -> Void) {
        completion(.success(dates))
    }
}

extension PayTransferServiceMock {
    var recipients: RecipientResponse {
        let data: Data = try! JSONHelper.resource(named: "recipients", bundle: MockDataBundle.bundle)

        return try! JSONDecoder().decode(RecipientResponse.self, from: data)
    }

    var amounts: AmountResponse {
        let data: Data = try! JSONHelper.resource(named: "amounts", bundle: MockDataBundle.bundle)

        return try! JSONDecoder().decode(AmountResponse.self, from: data)
    }

    var dates: DateResponse {
        let data: Data = try! JSONHelper.resource(named: "dates", bundle: MockDataBundle.bundle)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try! decoder.decode(DateResponse.self, from: data)
    }
}
