//
//  ProvidesL10nRule.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/19/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class ProvidesL10nRule: TestRule {
    
    private let l10nFilePath: String
    
    init(l10nFilePath: String) {
        self.l10nFilePath = l10nFilePath
    }
    
    func setup(_ app: XCUIApplication) {
        app.launchArguments += ["UI-Testing-Provides-L10n"]
    }
    
    func rulesHaveBeenSetup(otherRules: [TestRule]) {
        guard let mockServerRule = otherRules.first(where: { $0 is MockServerRule }) as? MockServerRule else {
            fatalError("ProvidesL10nRule must be used with MockServerRule")
        }
        
        mockServerRule.get("/l10n/json", jsonPath: l10nFilePath)
    }
    
    func tearDown(_ app: XCUIApplication) {}
}
