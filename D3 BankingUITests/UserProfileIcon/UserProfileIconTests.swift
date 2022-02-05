//
//  UserProfileIconTests.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 2/4/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class UserProfileIconTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
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

    func testUserProfileIconAppears() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        // Make sure that the dashboard appears
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())

        // Make sure that the profile icon appears in the navigation bar.
        let profileIconButton = app.buttons["profileIconBarButtonItem"]
        XCTAssert(profileIconButton.waitForExistence())
    }

    func testTouchingUserProfileIconShowsActionSheetWithUsernameAndLastLoginWhenPresent() {
        mockServerRule.get("/auth/session", jsonPath: "ProfileIconSessions/session-with-last-login.json")
        engageProfileIcon()

        // Make sure that the username shows in the action sheet
        XCTAssert(
            app.sheets.staticTexts["Samuel Adams III"].waitForExistence()
        )

        // Make sure that the last login time shows in the action sheet.
        XCTAssert(
            // The test l10n provider doesn't actually do the substitution pramaters.
            app.sheets.staticTexts["userProfile.lastLogin"].waitForExistence()
        )
    }

    func testTouchingUserProfileIconShowsActionSheetWithUsernameAndNoLastLogin() {
        mockServerRule.get("/auth/session", jsonPath: "ProfileIconSessions/session-without-last-login.json")
        engageProfileIcon()

        // Make sure that the username shows in the action sheet
        XCTAssert(
            app.sheets.staticTexts["Samuel Adams III"].waitForExistence()
        )

        // Make sure that the last login time does not show in the action sheet.
        XCTAssertFalse(
            // The test l10n provider doesn't actually do the substitution pramaters.
            app.sheets.staticTexts["userProfile.lastLogin"].waitForExistence()
        )
    }
    
    func testTouchingUserProfileIconShowsActionSheetWithProfileOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()
        
        let profileEditButton = app.buttons["nav.my.profile"]
        XCTAssert(profileEditButton.waitForExistence())
    }

    func testTouchingUserProfileIconShowsActionSheetWithProfileAlertSettingsOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()
        
        let profileAlertsButton = app.buttons["nav.profile.alert-settings"]
        XCTAssert(profileAlertsButton.waitForExistence())
    }

    func testTouchingUserProfileIconShowsActionSheetWithUserManagementOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()
        
        let userManagementButton = app.buttons["nav.profile.user-management"]
        XCTAssert(userManagementButton.waitForExistence())
    }
    
    func testTouchingUserProfileIconShowsActionSheetWithoutUserManagementOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session-without-usermanagement-permission.json")
        engageProfileIcon()
        
        let userManagementButton = app.buttons["nav.profile.user-management"]
        XCTAssertFalse(userManagementButton.waitForExistence())
    }

    func testTouchingUserProfileIconShowsActionSheetWithMyPreferencesOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()

        let myPreferencesButton = app.buttons["nav.profile.my-preferences"]
        XCTAssertTrue(myPreferencesButton.waitForExistence())
    }

    func testTouchingUserProfileIconShowsActionSheetWithLogoutOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()
        
        let logoutButton = app.buttons["Logout"]
        XCTAssert(logoutButton.waitForExistence())
    }
    
    func testTouchingUserProfileIconShowsActionSheetWithCancelOption() {
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        engageProfileIcon()
        
        let cancelButton = app.buttons["app.alert.btn.cancel"]
        XCTAssert(cancelButton.waitForExistence())
    }
    
    private func engageProfileIcon() {
        proceedToDashboard()

        // Make sure that the profile icon appears in the navigation bar.
        let profileIconButton = app.buttons["profileIconBarButtonItem"]
        XCTAssert(profileIconButton.waitForExistence())

        profileIconButton.tap()
    }

    private func proceedToDashboard() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }

        app.launch()

        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()

        // Make sure that the dashboard appears
        Thread.sleep(forTimeInterval: 4)
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }
}
