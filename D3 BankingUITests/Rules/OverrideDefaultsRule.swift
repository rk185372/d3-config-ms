//
//  OverrideDefaultsRule.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 4/1/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class OverrideDefaultsRule: TestRule {
    struct Default {
        let key: String
        let value: String
    }
    
    private let defaults: [Default]
    
    init(defaults: [Default]) {
        self.defaults = defaults
    }
    
    func setup(_ app: XCUIApplication) {
        defaults.forEach { overrideDefault in
            app.launchArguments.append("-\(overrideDefault.key)")
            app.launchArguments.append(overrideDefault.value)
        }
    }
    
    func rulesHaveBeenSetup(otherRules: [TestRule]) {}
    
    func tearDown(_ app: XCUIApplication) {}
}
