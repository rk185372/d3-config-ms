//
//  AppInitializationTests.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/21/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class AppInitializationTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "app-initialization/app-initialization-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()
    
    func testLoadingIndicatorIsDisplayed() {
        mockServerRule.get("/startup/mobile-initialization",
                           jsonPath: "app-initialization/app-initialization.json",
                           delay: .delay(seconds: 8))
        
        app.launch()
        
        XCTAssertTrue(app.activityIndicators.firstMatch.exists)
    }
    
    func testRetryIsDisplayedOnFail() {
        app.launch()
        
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence())
    }
    
    func testOptionalUpgradeShowsBothOptions() {
        mockServerRule.get("/startup/mobile-initialization",
                           jsonPath: "app-initialization/optional-upgrade-mobile-initialization.json")
        
        app.launch()
        
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence())
        XCTAssertTrue(app.buttons["Cancel"].exists)
    }
    
    func testMandatoryUpgradeOnlyShowsUpgradeButton() {
        mockServerRule.get("/startup/mobile-initialization",
                           jsonPath: "app-initialization/mandatory-upgrade-mobile-initialization.json")
        
        app.launch()
        
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence())
        XCTAssertFalse(app.buttons["Cancel"].exists)
    }
    
    func testUpgradeCancelButtonDismissesScreen() {
        mockServerRule.prefix(jsonPath: "CommonData/standard-startup") { router in
            router.get("/startup/ui", jsonPath: "/startup/ui.json")
            router.get("/view/quick", jsonPath: "/view/quick.json")
            router.get("/auth/challenge", jsonPath: "/auth/challenge.json")
        }
        mockServerRule.get("/startup/mobile-initialization",
                           jsonPath: "app-initialization/optional-upgrade-mobile-initialization.json")
        
        app.launch()
        
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence())
        cancelButton.tap()
        
        XCTAssertTrue(app.buttons["Submit"].waitForExistence())
    }
}
