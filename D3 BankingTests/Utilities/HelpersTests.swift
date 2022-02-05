//
//  HelpersTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 1/7/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import Utilities
import XCTest

final class HelpersTests: XCTestCase {
    func testCombineArr() {
        let test1 = ["A", "B", "C", "Some", "Q", "R", "S"]
        XCTAssertEqual(
            Helpers.handleAcronyms(in: test1),
            ["ABC", "Some", "QRS"]
        )

        let test2 = ["Some", "A", "B", "CD", "E"]
        XCTAssertEqual(
            Helpers.handleAcronyms(in: test2),
            ["Some", "AB", "CD", "E"]
        )

        let test3 = ["Some", "Thing", "Else"]
        XCTAssertEqual(
            Helpers.handleAcronyms(in: test3),
            ["Some", "Thing", "Else"]
        )

        let test4 = [String]()
        XCTAssertEqual(
            Helpers.handleAcronyms(in: test4),
            []
        )
    }
}
