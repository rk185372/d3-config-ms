//
//  MFATests.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/18/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class MFATests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()
    
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
    
    func testRadioItemEmailInputIsDisplayedWhenChoiceIsSelected() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-input-email.json")
        }
        
        app.launch()
        
        goToSecondaryAuthScreen()

        let radioButton = app.buttons["radio-I want to use an email not listed here"]
        let textField = app.textFields["Email"]
        XCTAssertTrue(radioButton.waitForExistence())
        XCTAssertFalse(radioButton.isSelected)
        XCTAssertFalse(textField.exists)
        
        radioButton.tap()
        print(radioButton.isSelected)
        
        XCTAssertTrue(radioButton.isSelected)
        XCTAssertTrue(textField.waitForExistence())

        let tooltip = app.staticTexts["Once signed in, update your profile with this new email address"]
        XCTAssertTrue(tooltip.waitForExistence())
    }

    func testRadioItemVoiceInputIsDisplayedWhenChoiceIsSelected() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-input-voice.json")
        }

        app.launch()

        goToSecondaryAuthScreen()

        let radioButton = app.buttons["radio-credentials.mfa-voice.new"]
        let textField = app.textFields["credentials.mfa-voice.input-placeholder"]
        XCTAssertTrue(radioButton.waitForExistence())
        XCTAssertFalse(radioButton.isSelected)
        XCTAssertFalse(textField.exists)

        radioButton.tap()
        print(radioButton.isSelected)

        XCTAssertTrue(radioButton.isSelected)
        XCTAssertTrue(textField.waitForExistence())

        let tooltip = app.staticTexts["credentials.mfa-voice.rates-disclosure"]
        XCTAssertTrue(tooltip.waitForExistence())
    }

    func testRadioItemSMSInputIsDisplayedWhenChoiceIsSelected() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-input-sms.json")
        }

        app.launch()

        goToSecondaryAuthScreen()

        let radioButton = app.buttons["radio-credentials.mfa-sms.new"]
        let textField = app.textFields["credentials.mfa-sms.input-placeholder"]
        XCTAssertTrue(radioButton.waitForExistence())
        XCTAssertFalse(radioButton.isSelected)
        XCTAssertFalse(textField.exists)

        radioButton.tap()
        print(radioButton.isSelected)

        XCTAssertTrue(radioButton.isSelected)
        XCTAssertTrue(textField.waitForExistence())

        let tooltip = app.staticTexts["credentials.mfa-sms.rates-disclosure"]
        XCTAssertTrue(tooltip.waitForExistence())
    }

    func testMethodChoiceShows() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-standard.json")
        }

        app.launch()

        goToSecondaryAuthScreen()
        XCTAssert(mfaMethodSelectionAppears())
    }
    
    func testRadioButtonCanBeDisabled() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-disabled.json")
        }
        
        app.launch()
        
        goToSecondaryAuthScreen()

        let enabledRadioButton = app.buttons["radio-enabled@gmail.com"]
        XCTAssertTrue(enabledRadioButton.waitForExistence())
        XCTAssertTrue(enabledRadioButton.isEnabled)
        
        XCTAssertFalse(enabledRadioButton.isSelected)
        enabledRadioButton.tap()
        XCTAssertTrue(enabledRadioButton.isSelected)
        
        let disabledRadioButton = app.buttons["radio-disabled@gmail.com"]
        XCTAssertTrue(disabledRadioButton.waitForExistence())
        XCTAssertFalse(disabledRadioButton.isEnabled)
        
        XCTAssertFalse(disabledRadioButton.isSelected)
        disabledRadioButton.tap()
        XCTAssertFalse(disabledRadioButton.isSelected)
    }

    func testNewQuestionValidation() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-new-question.json")
        }

        app.launch()

        goToSecondaryAuthScreen()
        XCTAssert(mfaQuestionAppears())
    }
    
    func testRadioButtonRegexValidation() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-radio-validation.json")
        }
        
        app.launch()
        
        goToSecondaryAuthScreen()

        let errorLabel = app.staticTexts["Error Regex"]
        XCTAssertFalse(errorLabel.exists)
        
        let newRadioButton = app.buttons["radio-I want to use an email not listed here"]
        XCTAssertTrue(newRadioButton.waitForExistence())
        newRadioButton.tap()
        
        let inputField = app.textFields["Email"]
        XCTAssertTrue(inputField.waitForExistence())
        inputField.focusAndType("bla")
        
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        
        XCTAssertTrue(errorLabel.exists)
        
        inputField.focusAndType("example@example.com")
        
        nextButton.tap()
        
        XCTAssertFalse(errorLabel.exists)
    }
    
    func testRadioButtonLengthValidation() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-radio-validation.json")
        }
        
        app.launch()
        
        goToSecondaryAuthScreen()
        
        let errorLabel = app.staticTexts["Error Length"]
        XCTAssertFalse(errorLabel.exists)
        
        let newRadioButton = app.buttons["radio-I want to use an email not listed here"]
        XCTAssertTrue(newRadioButton.waitForExistence())
        newRadioButton.tap()
        
        let inputField = app.textFields["Email"]
        XCTAssertTrue(inputField.exists)
        inputField.focusAndType("")
        
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        
        XCTAssertTrue(errorLabel.exists)
        
        inputField.focusAndType("example@example.com")
        
        nextButton.tap()
        
        XCTAssertFalse(errorLabel.exists)
    }

    func testCancelButtonShowsPrompt() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-radio-validation.json")
        }

        app.launch()

        goToSecondaryAuthScreen()

        let cancelButton = app.buttons["credentials.mfa-email.btn.cancel"]
        cancelButton.tap()

        XCTAssertTrue(app.staticTexts["Cancel Confirmation"].waitForExistence())
    }

    func testConfirmationScreenAppears() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-completion.json")
        }

        app.launch()

        goToSecondaryAuthScreen()

        XCTAssertTrue(app.staticTexts["Congratulations"].waitForExistence())
        XCTAssertTrue(app.staticTexts["We have successfully verified your MFA destination."].waitForExistence())
        XCTAssertTrue(app.staticTexts["You have successfully completed MFA Enrollment."].waitForExistence())
        XCTAssertTrue(app.staticTexts["Next"].waitForExistence())
    }
    
    func testAbortButtonShowsPrompt() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/mfa-with-abort-action.json")
        }

        app.launch()

        goToSecondaryAuthScreen()

        let cancelButton = app.buttons["mfa-actions.generic.abort"]
        cancelButton.tap()

        XCTAssertTrue(app.staticTexts["MFA Title"].waitForExistence())
        XCTAssertTrue(app.staticTexts["MFA Text"].waitForExistence())
    }

    private func mfaVoiceEmailOrSMSSelectionAppears() -> Bool {
        return app.staticTexts["credentials.mfa-phone.description"].waitForExistence()
            && app.buttons["radio-XXX-XXX-7856"].waitForExistence()
            && app.buttons["radio-XXX-XXX-2668"].waitForExistence()
            && app.buttons["credentials.mfa-phone.btn.send-code"].waitForExistence()
            && app.buttons["credentials.mfa-phone.btn.different-option"].waitForExistence()
            && app.buttons["credentials.mfa-phone.btn.cancel"].waitForExistence()
    }

    private func mfaMethodSelectionAppears() -> Bool {
        return app.staticTexts["Multifactor Authentication Setup"].waitForExistence()
            && app.buttons["radio-Email"].waitForExistence()
            && app.buttons["radio-SMS"].waitForExistence()
            && app.staticTexts["Message and data rates may apply"].waitForExistence()
            && app.buttons["credentials.mfa-factor.btn.next"].waitForExistence()
            && app.buttons["credentials.mfa-factor.btn.cancel"].waitForExistence()
    }

    private func mfaQuestionAppears() -> Bool {
        return app.staticTexts["credentials.security-question.description"].waitForExistence()
            && app.staticTexts["credentials.security-question.pattern-description"].waitForExistence()
    }
    
    private func goToSecondaryAuthScreen() {
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
    }
}
