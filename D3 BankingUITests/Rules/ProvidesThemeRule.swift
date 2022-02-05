//
//  ProvidesThemeRule.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 4/2/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class ProvidesThemeRule: TestRule {
    private let themeFilePath: String
    
    init(themeFilePath: String) {
        self.themeFilePath = themeFilePath
    }
    
    func setup(_ app: XCUIApplication) {
        app.launchArguments += ["UI-Testing-Provides-Theme"]
    }
    
    func rulesHaveBeenSetup(otherRules: [TestRule]) {
        guard let mockServerRule = otherRules.first(where: { $0 is MockServerRule }) as? MockServerRule else {
            fatalError("ProvidesThemeRule must be used with MockServerRule")
        }
        
        mockServerRule.get("/theme/json", jsonPath: themeFilePath)
    }
    
    func tearDown(_ app: XCUIApplication) {}
}

final class ProvidesWebThemeRule: TestRule {
    private let themeFilePath: String
    
    init(themeFilePath: String) {
        self.themeFilePath = themeFilePath
    }
    
    func setup(_ app: XCUIApplication) {
        app.launchArguments += ["UI-Testing-Provides-Theme"]
    }
    
    func rulesHaveBeenSetup(otherRules: [TestRule]) {
        guard let mockServerRule = otherRules.first(where: { $0 is MockServerRule }) as? MockServerRule else {
            fatalError("ProvidesWebThemeRule must be used with MockServerRule")
        }
        
        mockServerRule.get("/webtheme/json", jsonPath: themeFilePath)
    }
    
    func tearDown(_ app: XCUIApplication) {}
}
