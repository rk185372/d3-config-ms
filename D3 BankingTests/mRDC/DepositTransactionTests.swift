//
//  DepositTransactionTests.swift
//  D3 BankingTests
//
//  Created by Elvin Bearden on 8/5/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import XCTest
@testable import mRDC

class DepositTransactionTests: XCTestCase {
    var model: DepositTransaction!

    func testDepositTransactionDateFormats() {
        model = DepositTransaction(
            transactionId: "1",
            formattedTransactionDateTime: Date(timeIntervalSince1970: 1596658336.641612),
            postedAmount: 100,
            adjustedAmount: 100,
            currentAmount: 100,
            status: "",
            confirmationNumber: "2"
        )

        let expectedDateAndTime = "\\d{2}\\/\\d{2}\\/\\d{4} at \\d{2}:12 PM [A-Z]{3}"

        let match = model.dateAndTimeString()?.range(of: expectedDateAndTime, options: .regularExpression)
        XCTAssertNotNil(match)

        let expectedDateOnly = "August 5, 2020"
        XCTAssertEqual(expectedDateOnly, model.dateString())
    }
}
