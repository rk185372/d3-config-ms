//
//  AuthenticationTests.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/13/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class AuthenticationTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()
    let overrideDefaultsRule: OverrideDefaultsRule = OverrideDefaultsRule(defaults: [
        .init(key: "performedSnapshotSetup", value: "1"),
        .init(key: "performedBiometricsSetup", value: "1")
    ])
    
    override func setUp() {
        super.setUp()
        
        mockServerRule.prefix(jsonPath: "CommonData/standard-startup") { router in
            router.prefix(path: "/startup", jsonPath: "/startup", router: { router in
                router.get("/ui", jsonPath: "/ui.json")
                router.get("/mobile-initialization", jsonPath: "/mobile-initialization.json")
            })
            router.get("/view/quick", jsonPath: "/view/quick.json")
        }
    }
    
    func testInitialAuthScreenIsDisplayed() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
    
        app.launch()
        
        XCTAssertTrue(app.textFields["Enter user name"].waitForExistence())
        XCTAssertTrue(app.secureTextFields["Enter password"].waitForExistence())
        XCTAssertTrue(app.buttons["Submit"].waitForExistence())
    }
    
    func testSecretQuestionPageDisplayed() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/secret-question-challenge.json")
        }
        
        app.launch()
        
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
        XCTAssertTrue(app.secureTextFields["Answer"].waitForExistence())
        XCTAssertTrue(app.buttons["Submit"].waitForExistence())
    }
    
    func testConfirmationDialogIsDisplayed() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/challenge-with-confirmation.json")
        }
        
        app.launch()
        
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
        
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence())
        cancelButton.tap()
        
        let alert = app.alerts["Cancel Confirmation"]
        XCTAssertTrue(alert.waitForExistence())
        XCTAssertTrue(alert.staticTexts["You want to cancel?"].exists)
    }
    
    func testConfirmationDialogWithTitle() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/challenge-with-confirmation-title.json")
        }
        
        app.launch()
        
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
        
        let cancelButton = app.buttons["Nope"]
        XCTAssertTrue(cancelButton.waitForExistence())
        cancelButton.tap()
        
        let alert = app.alerts["MFA Title"]
        XCTAssertTrue(alert.waitForExistence())
        XCTAssertTrue(alert.staticTexts["MFA Text"].exists)
    }
    
    func testSuccessfulAuthTransitionsToDashboard() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        
        app.launch()
        
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
        
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }
}
