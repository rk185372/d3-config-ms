//
//  ConsumerLoginTests.swift
//  D3 BankingUITests
//
//  Created by Jose Torres on 3/17/21.
//

import Foundation
import XCTest

final class ConsumerLoginTests: RuleBasedTest {
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
        
        let personalToggle = app.buttons["login.personal.toggle.title"]
        personalToggle.tap()
        
        XCTAssertTrue(app.textFields["Enter user name"].waitForExistence())
        XCTAssertTrue(app.secureTextFields["Enter password"].waitForExistence())
        XCTAssertTrue(app.buttons["Submit"].waitForExistence())
    }
    
    func testForgotUsernameAndForgotPasswordArePresented() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let personalToggle = app.buttons["login.personal.toggle.title"]
        personalToggle.tap()
        
        XCTAssertTrue(app.buttons["launchPage.forgotUsername.help.label"].exists)
        XCTAssertTrue(app.buttons["launchPage.forgotPassword.help.label"].exists)
        XCTAssertFalse(app.otherElements["login.business.username.save checkbox"].exists)
    }
    
    func testScrollviewMoreItems() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
    
        app.launch()
        
        let personalToggle = app.buttons["login.personal.toggle.title"]
        personalToggle.tap()
        
        app.swipeUp()
        
        XCTAssertTrue(app.buttons["launchPage.menu.more.label"].waitForExistence())
        var moreButton = app.buttons["launchPage.menu.more.label"]
        moreButton.tap()
        
        XCTAssertTrue(app.buttons["app.alert.btn.cancel"].waitForExistence())
    }
    
    func testSuccessfulLoginSavingUsernameLogoutAndRemovingSavedUsername() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")

        app.launch()

        let personalToggle = app.buttons["login.personal.toggle.title"]
        personalToggle.tap()
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")

        let rememberUsernameCheckbox = app.otherElements["login.remember-username checkbox"]
        XCTAssertTrue(rememberUsernameCheckbox.exists)
        rememberUsernameCheckbox.tap()

        let loginButton = app.buttons["Submit"]
        loginButton.tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
        waitForButtonExistanceAndTap("profileIconBarButtonItem")
        waitForButtonExistanceAndTap("Logout")
        
        _ = loginButton.waitForExistence()

        let usernameFilledButton = app.buttons["username-view-button"]
        XCTAssertFalse(app.textFields["Enter user name"].exists)
        XCTAssertTrue(usernameFilledButton.exists)

        usernameFilledButton.tap()
    }
    
    private func waitForButtonExistanceAndTap(_ key: String) {
        let button = app.buttons[key]
        XCTAssert(button.waitForExistence(), "\(key) not present in current view")
        button.tap()
    }
}
