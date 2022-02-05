//
//  RuleBasedTest.swift
//  D3 Banking
//
//  Created by Chris Carranza on 8/9/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

class RuleBasedTest: XCTestCase {
    let app = XCUIApplication()
    
    private typealias TestRuleProperty = (label: String?, value: TestRule)
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        print("Setup")
        let selfMirror = Mirror(reflecting: self)
        let testRules: [TestRuleProperty] = selfMirror.children.compactMap { child -> TestRuleProperty? in
            let (_, value) = child
            guard value is TestRule else { return nil }
            return child as? TestRuleProperty
        }
        for testRule in testRules {
            print("Found Rule: \(testRule.label!)")
            testRule.value.setup(app)
        }
        for testRule in testRules {
            let rulesExludingSelf = testRules.filter { (rule) -> Bool in
                return rule.label != testRule.label
            }
            
            testRule.value.rulesHaveBeenSetup(otherRules: rulesExludingSelf.map { $0.value })
        }

        app.launchEnvironment["animations"] = "0"
        app.launchArguments.append("UITests")
    }
    
    override func tearDown() {
        super.tearDown()
        
        print("Teardown")
        let selfMirror = Mirror(reflecting: self)
        for (_, value) in selfMirror.children {
            guard let testRule = value as? TestRule else { continue }
            testRule.tearDown(app)
        }
    }
}
