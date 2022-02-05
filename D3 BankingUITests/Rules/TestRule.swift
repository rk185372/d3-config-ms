//
//  TestRule.swift
//  D3 Banking
//
//  Created by Chris Carranza on 8/9/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

protocol TestRule {
    func setup(_ app: XCUIApplication)
    func rulesHaveBeenSetup(otherRules: [TestRule])
    func tearDown(_ app: XCUIApplication)
}
