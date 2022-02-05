//
//  BusinessLoginTests.swift
//  D3 BankingUITests
//
//  Created by Jose Torres on 3/17/21.
//

import Foundation
import XCTest

final class BusinessLoginTests: RuleBasedTest {
    let webViewMockData: String = "externalWebViewMockData"
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
    
    func testBusinessToggleIsDisplayed() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        XCTAssertTrue(app.buttons["login.personal.toggle.title"].waitForExistence())
        XCTAssertTrue(app.buttons["login.business.toggle.title"].waitForExistence())
    }
    
    func testBusinessToggleSelectionShowsBusinessOnlyOptions() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        businessToggle.tap()
        
        XCTAssertTrue(app.textFields["login.business.username.label"].waitForExistence())
        XCTAssertTrue(app.secureTextFields["Enter password"].waitForExistence())
        XCTAssertTrue(app.buttons["challenge-text-input-infobutton-EXCLAMATION_ICON"].waitForExistence())
        XCTAssertTrue(app.otherElements["login.business.username.save checkbox"].waitForExistence())
        XCTAssertTrue(app.buttons["login.business.btn.submit"].waitForExistence())
        XCTAssertTrue(app.buttons["login.business.forgot.user.password"].waitForExistence())
        XCTAssertTrue(app.buttons["login.business.self.enrollment"].waitForExistence())
        
        app.buttons["login.personal.toggle.title"].tap()
    }
    
    func testBusinessForgotUsernamePasswordIsOnlyHelpButtonVisible() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")

        app.launch()

        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()

        XCTAssertTrue(app.otherElements["login.business.username.save checkbox"].waitForExistence())
        XCTAssertFalse(app.buttons["launchPage.forgotUsername.help.label"].exists)
        XCTAssertFalse(app.buttons["launchPage.forgotPassword.help.label"].exists)
        
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessScrollviewLaunchpageMoreItems() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        app.launch()
        let businessToggle = app.buttons["login.business.toggle.title"]
        businessToggle.tap()
        
        app.swipeUp()
        
        XCTAssertTrue(app.buttons["launchPage.menu.more.label"].waitForExistence())
        let moreButtons = app.buttons["launchPage.menu.more.label"]
        moreButtons.tap()
        
        XCTAssertTrue(app.buttons["app.alert.btn.cancel"].waitForExistence())

    }
    
    func testBusinessToolTipShowsAndHidesWhenSavedUsernames() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")

        app.launch()

        waitForButtonExistanceAndTap("login.business.toggle.title")

        let businessUsernameTextfield = app.textFields["login.business.username.label"]
        businessUsernameTextfield.focusAndType("samualadamsiii")

        XCTAssert(businessUsernameTextfield.exists)
        XCTAssertTrue(app.buttons["challenge-text-input-infobutton-EXCLAMATION_ICON"].exists, "Exclamation Icon is not present")

        let enterPasswordTextfield = app.secureTextFields["Enter password"]
        _ = enterPasswordTextfield.waitForExistence()
        enterPasswordTextfield.focusAndType("password")

        let rememberUsernameCheckbox = app.otherElements["login.business.username.save checkbox"]
        XCTAssertTrue(rememberUsernameCheckbox.exists)
        rememberUsernameCheckbox.tap()

        let loginButton = app.buttons["login.business.btn.submit"]
        _ = loginButton.waitForExistence()
        loginButton.tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())

        waitForButtonExistanceAndTap("profileIconBarButtonItem")
        waitForButtonExistanceAndTap("Logout")
        _ = loginButton.waitForExistence()

        XCTAssertFalse(app.textFields["login.business.username.label"].exists)
        XCTAssertFalse(app.buttons["challenge-text-input-infobutton-EXCLAMATION_ICON"].exists, "Exclamation Icon is present")
    }
    
    func testBusinessToolTipSelectionShowsDialog() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let toolTipButton = app.buttons["challenge-text-input-infobutton-EXCLAMATION_ICON"]
        _ = toolTipButton.waitForExistence()
        toolTipButton.tap()
        
        XCTAssertTrue(app.staticTexts["LOGIN.BUSINESS.MODAL.TOOLTIP.TITLE"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.tooltip.subtitle"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.tooltip.item1"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.tooltip.item2"].waitForExistence())
        
        waitForButtonExistanceAndTap("𝖷")
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessToolTipDialogDismissAction() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let toolTipButton = app.buttons["challenge-text-input-infobutton-EXCLAMATION_ICON"]
        _ = toolTipButton.waitForExistence()
        toolTipButton.tap()
        
        let dismissButton = app.buttons["𝖷"]
        XCTAssertTrue(dismissButton.waitForExistence(), "Dismiss button not present in ToolTip Dialog")
        dismissButton.tap()
        
        XCTAssertFalse(app.staticTexts["LOGIN.BUSINESS.MODAL.TOOLTIP.TITLE"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.tooltip.subtitle"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.tooltip.item1"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.tooltip.item2"].exists)
        
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessForgotUsernamePasswordSelectionShowsDialog() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let businessForgotUsernamePasswordButton = app.buttons["login.business.forgot.user.password"]
        _ = businessForgotUsernamePasswordButton.waitForExistence()
        businessForgotUsernamePasswordButton.tap()
        
        XCTAssertTrue(app.staticTexts["LOGIN.BUSINESS.MODAL.LOGINHELP.TITLE"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.loginHelp.username.subtitle"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.loginHelp.username.ratio"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.loginHelp.password.subtitle"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.loginHelp.password.ratio"].waitForExistence())
        XCTAssertTrue(app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.MAIN"].waitForExistence())
        XCTAssertTrue(app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.DISMISS"].waitForExistence())
        
        waitForButtonExistanceAndTap("LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.DISMISS")
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessForgotUsernamePasswordDialogDismissAction() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let forgotUsernamePasswordButton = app.buttons["login.business.forgot.user.password"]
        _ = forgotUsernamePasswordButton.waitForExistence()
        forgotUsernamePasswordButton.tap()
        
        let dismissButton = app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.DISMISS"]
        XCTAssertTrue(dismissButton.waitForExistence(), "Dismiss button not present in ForgotUsernamePassword Dialog")
        dismissButton.tap()
        
        XCTAssertFalse(app.staticTexts["LOGIN.BUSINESS.MODAL.LOGINHELP.TITLE"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.loginHelp.username.subtitle"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.loginHelp.username.ratio"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.loginHelp.password.subtitle"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.loginHelp.password.ratio"].exists)
        XCTAssertFalse(app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.MAIN"].exists)
        XCTAssertFalse(app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.DISMISS"].exists)
        
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessForgotUsernamePasswordDialogMainAction() {
        let html = FileHelper.stringContents(of: "test-page", withType: "html", in: "ExternalWebViewContents")
        app.launchEnvironment[webViewMockData] = html
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")

        app.launch()

        waitForButtonExistanceAndTap("login.business.toggle.title")
        waitForButtonExistanceAndTap("login.business.forgot.user.password")

        let actionButton = app.buttons["LOGIN.BUSINESS.MODAL.LOGINHELP.BUTTON.MAIN"]
        XCTAssertTrue(actionButton.waitForExistence(), "Action button not present in ForgotUsernamePassword Dialog")
        actionButton.tap()

        XCTAssertTrue(app.staticTexts["Test html page"].waitForExistence())
    }
    
    func testBusinessEnrollmentSelectionShowsDialog() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let enrollmentButton = app.buttons["login.business.self.enrollment"]
        _ = enrollmentButton.waitForExistence()
        enrollmentButton.tap()
        
        XCTAssertTrue(app.staticTexts["LOGIN.BUSINESS.MODAL.ENROLLMENT.TITLE"].waitForExistence())
        XCTAssertTrue(app.staticTexts["login.business.modal.enrollment.subtitle"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item1"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item2"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item3"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item4"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item5"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item6"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item7"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item8"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item9"].waitForExistence())
        XCTAssertTrue(app.staticTexts["• login.business.modal.enrollment.item10"].waitForExistence())
        XCTAssertTrue(app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.MAIN"].waitForExistence())
        XCTAssertTrue(app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.DISMISS"].waitForExistence())
        
        waitForButtonExistanceAndTap("LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.DISMISS")
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessEnrollmentDialogDismissAction() {
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launch()
        
        let businessToggle = app.buttons["login.business.toggle.title"]
        _ = businessToggle.waitForExistence()
        businessToggle.tap()
        
        let enrollmentButton = app.buttons["login.business.self.enrollment"]
        _ = enrollmentButton.waitForExistence()
        enrollmentButton.tap()
        
        let dismissButton = app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.DISMISS"]
        XCTAssertTrue(dismissButton.waitForExistence(), "Dismiss button not present in Enrollment Dialog")
        dismissButton.tap()
        
        XCTAssertFalse(app.staticTexts["LOGIN.BUSINESS.MODAL.ENROLLMENT.TITLE"].exists)
        XCTAssertFalse(app.staticTexts["login.business.modal.enrollment.subtitle"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item1"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item2"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item3"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item4"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item5"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item6"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item7"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item8"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item9"].exists)
        XCTAssertFalse(app.staticTexts["• login.business.modal.enrollment.item10"].exists)
        XCTAssertFalse(app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.MAIN"].exists)
        XCTAssertFalse(app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.DISMISS"].exists)
        
        waitForButtonExistanceAndTap("login.personal.toggle.title")
    }
    
    func testBusinessEnrollmentDialogMainAction() {
        let html = FileHelper.stringContents(of: "test-page", withType: "html", in: "ExternalWebViewContents")
        app.launchEnvironment[webViewMockData] = html

        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")

        app.launch()

        waitForButtonExistanceAndTap("login.business.toggle.title")
        waitForButtonExistanceAndTap("login.business.self.enrollment")

        let actionButton = app.buttons["LOGIN.BUSINESS.MODAL.ENROLLMENT.BUTTON.MAIN"]
        XCTAssertTrue(actionButton.waitForExistence(), "Action button not present in Enrollment Dialog")
        actionButton.tap()

        XCTAssertTrue(app.staticTexts["Test html page"].waitForExistence())
    }
    
    private func waitForButtonExistanceAndTap(_ key: String) {
        let button = app.buttons[key]
        XCTAssert(button.waitForExistence(), "\(key) not present in current view")
        button.tap()
    }
}
