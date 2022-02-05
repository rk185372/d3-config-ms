//
//  WebViewTests.swift
//  D3 BankingUITests
//
//  Created by Jose Torres on 10/14/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class WebViewTests: RuleBasedTest {
    let webViewMockData: String = "webViewMockData"
    let externalWebViewMockData: String = "externalWebViewMockData"
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
        mockServerRule.get("/auth/challenge", jsonPath: "authentication/initial-challenge.json")
        
        app.launchArguments.append("webViewsLoadFromFiles")
    }

    func testZelleFiservBridgeCallToAddFromDeviceWithPhoneOption() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        let htmlZelle = FileHelper.stringContents(of: "zelle-contact-bridge", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        app.launchEnvironment[externalWebViewMockData] = htmlZelle

        app.launch()

        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        let openZelleButton = app.buttons["Open Zelle"]
        XCTAssert(openZelleButton.waitForExistence())
        openZelleButton.tap()

        let zelleBridge = app.staticTexts["Zelle Bridge"]
        XCTAssert(zelleBridge.waitForExistence())
        zelleBridge.tap()

        let title = app.staticTexts["Contacts"]
        XCTAssert(title.waitForExistence(), "ContactPicker did not appear")

        let contactSample = app.staticTexts["John Appleseed"]
        XCTAssert(contactSample.waitForExistence(), "Did not find contact named John Appleseed")
        contactSample.tap()

        let homePhoneCell = app.tables.firstMatch.cells["home"]
        XCTAssert(homePhoneCell.waitForExistence(), "Did not find home phone number for contact")
        homePhoneCell.tap()

        Thread.sleep(forTimeInterval: 1)

        assertPageContains("\"tokenValue\":\"888-555-1212\"", "Did not receive phone number")
        assertPageContains("\"firstName\":\"John\"", "Did not receive first name")
        assertPageContains("\"lastName\":\"Appleseed\"", "Did not receive last name")
        assertPageContains("\"tokenType\":\"phone\"", "Did not receive type")

        app.launchEnvironment[webViewMockData] = nil
    }
    
    func testZelleFiservBridgeCallToAddFromDeviceWithEmailOption() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        let htmlZelle = FileHelper.stringContents(of: "zelle-contact-bridge", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        app.launchEnvironment[externalWebViewMockData] = htmlZelle

        app.launch()

        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        let openZelleButton = app.buttons["Open Zelle"]
        XCTAssert(openZelleButton.waitForExistence())
        openZelleButton.tap()

        let zelleBridge = app.staticTexts["Zelle Bridge"]
        XCTAssert(zelleBridge.waitForExistence())
        zelleBridge.tap()

        let title = app.staticTexts["Contacts"]
        XCTAssert(title.waitForExistence(), "ContactPicker did not appear")

        let contactSample = app.staticTexts["John Appleseed"]
        XCTAssert(contactSample.waitForExistence(), "Did not find contact named John Appleseed")
        contactSample.tap()

        let workEmailCell = app.tables.firstMatch.cells["work"]
        XCTAssert(workEmailCell.waitForExistence(), "Did not find work email for contact")
        workEmailCell.tap()

        Thread.sleep(forTimeInterval: 1)

        assertPageContains("\"tokenValue\":\"John-Appleseed@mac.com\"", "Did not receive email")
        assertPageContains("\"firstName\":\"John\"", "Did not receive first name")
        assertPageContains("\"lastName\":\"Appleseed\"", "Did not receive last name")
        assertPageContains("\"tokenType\":\"email\"", "Did not receive type")

        app.launchEnvironment[webViewMockData] = nil
    }
    
    func testZelleFiservBridgeCallToTimeOut() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        let htmlZelle = FileHelper.stringContents(of: "zelle-contact-bridge", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        app.launchEnvironment[externalWebViewMockData] = htmlZelle

        app.launch()

        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        let openZelleButton = app.buttons["Open Zelle"]
        XCTAssert(openZelleButton.waitForExistence())
        openZelleButton.tap()

        let zelleBridge = app.staticTexts["Zelle Bridge"]
        XCTAssert(zelleBridge.waitForExistence())
        zelleBridge.tap()

        let timeOutBridge = app.staticTexts["Perform Timeout"]
        XCTAssert(timeOutBridge.waitForExistence())
        timeOutBridge.tap()

        app.launchEnvironment[webViewMockData] = nil
    }
    
    func testLogoOutWebMessage() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        
        app.launch()

        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        let logOutButton = app.buttons["Log Out"]
        XCTAssert(logOutButton.waitForExistence())
        logOutButton.tap()
        
        let usernameTextField = app.textFields["Enter user name"]
        let passwordTextField = app.secureTextFields["Enter password"]
        XCTAssert(usernameTextField.waitForExistence())
        XCTAssert(passwordTextField.waitForExistence())
    }
    
    func testAllowTabSwitchWebMessageContinueAction() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        
        app.launch()
        
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()
        
        let stopSwitchingTabButton = app.buttons["Stop Switch Tab"]
        XCTAssert(stopSwitchingTabButton.waitForExistence())
        stopSwitchingTabButton.tap()
        
        // Make sure that the Alert appears
        Thread.sleep(forTimeInterval: 5)
        
        app.tabBars.buttons.element(boundBy: 2).tap()
        
        let errorAlertView = app.alerts["Alert Payment"]
        let errorText = errorAlertView.staticTexts["Payment is in-progress"]
        XCTAssert(errorAlertView.waitForExistence())
        XCTAssertTrue(errorText.exists)
        XCTAssertTrue(errorAlertView.buttons.count == 2)
        
        let confirmButton = errorAlertView.buttons["Confirm"]
        if confirmButton.exists {
            confirmButton.tap()
            XCTAssertFalse(app.navigationBars.staticTexts["Accounts"].exists)
        }
    }
    
    func testAllowTabSwitchWebMessageCancelAction() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        
        app.launch()
        
        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()
        
        let stopSwitchingTabButton = app.buttons["Stop Switch Tab"]
        XCTAssert(stopSwitchingTabButton.waitForExistence())
        stopSwitchingTabButton.tap()
        
        // Make sure that the Alert appears
        Thread.sleep(forTimeInterval: 5)
        
        app.tabBars.buttons.element(boundBy: 2).tap()
        
        let errorAlertView = app.alerts["Alert Payment"]
        let errorText = errorAlertView.staticTexts["Payment is in-progress"]
        XCTAssert(errorAlertView.waitForExistence())
        XCTAssertTrue(errorText.exists)
        XCTAssertTrue(errorAlertView.buttons.count == 2)
        
        let cancelButton = errorAlertView.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
            XCTAssertTrue(app.navigationBars.staticTexts["Accounts"].exists)
        }
    }
    
    func testLogoOutWebMessageWithError() {
        let html = FileHelper.stringContents(of: "test-actions-page", withType: "html", in: "WebViewContents")
        app.launchEnvironment[webViewMockData] = html
        
        app.launch()

        mockServerRule.get("/auth/session", jsonPath: "CommonData/standard-startup/auth/session.json")
        proceedToDashboard()

        let logOutButton = app.buttons["Log Out with Error"]
        XCTAssert(logOutButton.waitForExistence())
        logOutButton.tap()

        let errorAlertView = app.alerts["Alert Title"]
        let errorText = errorAlertView.staticTexts["Error message description"]
        XCTAssert(errorAlertView.waitForExistence())
        XCTAssertTrue(errorText.exists)
    }
    
    func assertPageContains(_ text: String, _ message: String) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let elementQuery = app.staticTexts.containing(predicate)
        // swiftlint:disable:next empty_count
        XCTAssertTrue(elementQuery.count > 0, message)
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
