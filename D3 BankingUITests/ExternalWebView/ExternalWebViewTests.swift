//
//  ExternalWebViewTests.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 2/7/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class ExternalWebViewTests: RuleBasedTest {
    let webViewMockData: String = "externalWebViewMockData"
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
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")

        app.launchArguments.append("webViewsLoadFromFiles")
    }

    func testPassingUsernameToAuthViewControllerWorksWithNonEncodedValueOnShowsCharsBeforeDelimiter() {
        let html = FileHelper.stringContents(of: "test-username-passing-non-encoded", withType: "html", in: "ExternalWebViewContents")
        app.launchEnvironment[webViewMockData] = html

        app.launch()

        let usernameTextField = app.textFields["challenge-text-input-username"]
        openWebViewAndTouchLink(with: usernameTextField)

        XCTAssert(usernameTextField.value as! String == "user")

        app.launchEnvironment[webViewMockData] = nil
    }

    func testPassingUsernameWithPercentEncodingFunctionsCorrectly() {
        let html = FileHelper.stringContents(of: "test-username-passing-percent-encoded", withType: "html", in: "ExternalWebViewContents")
        app.launchEnvironment[webViewMockData] = html

        app.launch()

        let usernameTextField = app.textFields["challenge-text-input-username"]
        openWebViewAndTouchLink(with: usernameTextField)

        XCTAssert(
            usernameTextField.waitForExistence(),
            "Did not find username text field after web view was dismissed"
        )

        XCTAssert(
            usernameTextField.value as! String == "user#name",
            "Username text field's value was not as expected"
        )

        app.launchEnvironment[webViewMockData] = nil
    }

    private func openWebViewAndTouchLink(with usernameTextField: XCUIElement) {
        XCTAssertTrue(usernameTextField.waitForExistence())
        XCTAssertTrue(usernameTextField.value as! String == "Enter user name")

        let passwordTextField = app.secureTextFields["challenge-text-input-password"]
        XCTAssertTrue(passwordTextField.waitForExistence())

        XCTAssertTrue(app.buttons["Submit"].waitForExistence())

        // The standard auth startup has the elements for the forgot username button
        // configured so the forgot username button should be present.
        let forgotUsernameButton = app.buttons["launchPage.forgotUsername.help.label"]
        XCTAssert(forgotUsernameButton.waitForExistence())

        forgotUsernameButton.tap()

        Thread.sleep(forTimeInterval: 2)
        
        let link = app.staticTexts["Touch Here"]
        XCTAssert(link.waitForExistence())

        link.tap()
    }
    
    func testPassingErrorMessageAfterSignOut() {
        let html = FileHelper.stringContents(of: "test-errormessage-passing", withType: "html", in: "ExternalWebViewContents")
        app.launchEnvironment[webViewMockData] = html

        app.launch()
        
        let usernameTextField = app.textFields["challenge-text-input-username"]
        openWebViewAndTouchLink(with: usernameTextField)
        
        let alert = app.alerts["Alert Title"]
        XCTAssertTrue(alert.waitForExistence())
        XCTAssertTrue(alert.staticTexts["App closed due to bad connection"].exists)
        app.launchEnvironment[webViewMockData] = nil
    }

}
