//
//  String+TransformTests.swift
//  D3 BankingTests
//
//  Created by Andrew Watt on 8/30/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import XCTest
import Utilities

class String_TransformTests: XCTestCase {
    func testAbbreviated() {
        var abbreviation = "alfa bravo charlie delta".abbreviated(length: 3)
        XCTAssertEqual("ABC", abbreviation)

        abbreviation = "alfa bravo charlie delta".abbreviated()
        XCTAssertEqual("AB", abbreviation)

        abbreviation = "checking".abbreviated()
        XCTAssertEqual("CH", abbreviation)
        
        abbreviation = "1 savings account".abbreviated()
        XCTAssertEqual("SA", abbreviation)

        abbreviation = "mom's deposit account".abbreviated()
        XCTAssertEqual("MD", abbreviation)

        abbreviation = "checking-new account".abbreviated()
        XCTAssertEqual("CN", abbreviation)
    }

    func testCamelize() {
        let expectedResult = "iosIsTheBest"

        XCTAssertEqual(
            "ios_is_the_best".camelize(),
            expectedResult
        )

        XCTAssertEqual(
            "ios-is-the-best".camelize(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is the best".camelize(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is_the-best".camelize(),
            expectedResult
        )
    }

    func testCapitalize() {
        XCTAssertEqual(
            "ios_is_best".capitalize(),
            "Ios_is_best"
        )

        XCTAssertEqual(
            "ios is best".capitalize(),
            "Ios is best"
        )

        XCTAssertEqual(
            "Ios is best".capitalize(),
            "Ios is best"
        )

        XCTAssertEqual(
            "".capitalize(),
            ""
        )
    }

    func testConvertToTitle() {
        let expectedResult = "Ios Is Best"

        XCTAssertEqual(
            "ios_is_best".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is-best".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is best".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "IosIsBest".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "iosIsBest".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "ios_is-best".convertToTitle(),
            expectedResult
        )

        XCTAssertEqual(
            "Account_APR".convertToTitle(),
            "Account APR"
        )

        XCTAssertEqual(
            "YTD_Date".convertToTitle(),
            "YTD Date"
        )
    }

    func testDecapitalize() {
        XCTAssertEqual(
            "Ios is best".decapitalize(),
            "ios is best"
        )

        XCTAssertEqual(
            "Ios_is_best".decapitalize(),
            "ios_is_best"
        )

        XCTAssertEqual(
            "ios is best".decapitalize(),
            "ios is best"
        )

        XCTAssertEqual(
            "".decapitalize(),
            ""
        )
    }

    func testDasherize() {
        XCTAssertEqual(
            "iosIsBest".dasherize(),
            "ios-Is-Best"
        )

        XCTAssertEqual(
            "ios is best".dasherize(),
            "ios-is-best"
        )

        XCTAssertEqual(
            "ios_is_best".dasherize(),
            "ios-is-best"
        )

        XCTAssertEqual(
            "ios is_best".dasherize(),
            "ios-is-best"
        )
    }

    func testHumanize() {
        let expectedResult = "Ios is best"

        XCTAssertEqual(
            "ios_is_best".humanize(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is best".humanize(),
            expectedResult
        )

        XCTAssertEqual(
            "".humanize(),
            ""
        )
    }

    func testTitleize() {
        XCTAssertEqual(
            "ios_is_best".titleize(),
            "Ios_Is_Best"
        )

        XCTAssertEqual(
            "ios-is-best".titleize(),
            "Ios-Is-Best"
        )

        XCTAssertEqual(
            "ios_is-best".titleize(),
            "Ios_Is-Best"
        )

        XCTAssertEqual(
            "ios is best".titleize(),
            "Ios Is Best"
        )
    }

    func testUnderscored() {
        let expectedResult = "ios_is_best"

        XCTAssertEqual(
            "iosIsBest".underscored(),
            expectedResult
        )

        XCTAssertEqual(
            "ios is best".underscored(),
            expectedResult
        )

        XCTAssertEqual(
            "ios-is best".underscored(),
            expectedResult
        )

        XCTAssertEqual(
            "".underscored(),
            ""
        )
    }
}
