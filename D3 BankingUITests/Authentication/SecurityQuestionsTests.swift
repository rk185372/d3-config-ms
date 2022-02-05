//
//  SecurityQuestionsTests.swift
//  D3 BankingUITests
//
//  Created by Elvin Bearden on 9/3/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import XCTest

final class SecurityQuestionsTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()

    let overrideDefaultsRule: OverrideDefaultsRule = OverrideDefaultsRule(defaults: [
        .init(key: "performedSnapshotSetup", value: "0"),
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

    func testSuccess() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/post-authentication-session.json")
        }

        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }

        login()

        let securityQuestion = app.staticTexts.containing(NSPredicate(format: "label contains[cd] '?'")).firstMatch
        securityQuestion.tap()

        XCTAssertTrue(securityQuestion.waitForExistence())
        XCTAssertTrue(app.staticTexts["credentials.security-question.description"].waitForExistence())
        XCTAssertTrue(app.buttons["credentials.security-question.submit"].waitForExistence())
        XCTAssertTrue(app.buttons["credentials.security-question.cancel"].waitForExistence())

        let favoriteSport = app.staticTexts["What's your favorite sport?"].firstMatch
        XCTAssertTrue(app.staticTexts["credentials.security-question.description"].waitForExistence())
        XCTAssertTrue(app.staticTexts["Example Challenge Question?"].waitForExistence())
        XCTAssertTrue(app.staticTexts["Another Question?"].waitForExistence())
        XCTAssertTrue(favoriteSport.waitForExistence())
        favoriteSport.tap()

        app.secureTextFields["Answer"].focusAndType("Skiing")
        app.buttons["credentials.security-question.submit"].tap()

        XCTAssertTrue(app.staticTexts["device.config-snapshot.title"].waitForExistence())
    }

    func testAnswerTooShortFailure() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/post-authentication-session.json")
        }

        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }

        login()

        let securityQuestion = app.staticTexts.containing(NSPredicate(format: "label contains[cd] '?'")).firstMatch
        securityQuestion.tap()

        let favoriteSport = app.staticTexts["What's your favorite sport?"].firstMatch
        favoriteSport.tap()

        app.secureTextFields["Answer"].focusAndType("N")
        app.buttons["credentials.security-question.submit"].tap()

        XCTAssertTrue(app.staticTexts["credentials.security-question.validate.min"].waitForExistence())
    }

    func testAnswerTooLongFailure() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/post-authentication-session.json")
        }

        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }

        login()

        let securityQuestion = app.staticTexts.containing(NSPredicate(format: "label contains[cd] '?'")).firstMatch
        securityQuestion.tap()

        let favoriteSport = app.staticTexts["What's your favorite sport?"].firstMatch
        favoriteSport.tap()

        let longText = "I like to go on long walks on the beach and play volleyball with my fellow air force pilots"
        app.secureTextFields["Answer"].focusAndType(longText)
        app.buttons["credentials.security-question.submit"].tap()

        XCTAssertTrue(app.staticTexts["credentials.security-question.validate.max"].waitForExistence())
    }

    func testDisallowedCharactersFailure() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/post-authentication-session.json")
        }

        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }

        login()

        let securityQuestion = app.staticTexts.containing(NSPredicate(format: "label contains[cd] '?'")).firstMatch
        securityQuestion.tap()

        let favoriteSport = app.staticTexts["What's your favorite sport?"].firstMatch
        favoriteSport.tap()

        app.secureTextFields["Answer"].focusAndType("I can't enter a question mark or a number like 9?")
        app.buttons["credentials.security-question.submit"].tap()

        XCTAssertTrue(app.staticTexts["Your answer contains invalid characters"].waitForExistence())
    }

    func testFailureShowsDialog() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/post-authentication-session.json")
        }

        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers-failure.json", status: .failure)
        }

        login()

        let securityQuestion = app.staticTexts.containing(NSPredicate(format: "label contains[cd] '?'")).firstMatch
        securityQuestion.tap()

        let favoriteSport = app.staticTexts["What's your favorite sport?"].firstMatch
        favoriteSport.tap()

        app.secureTextFields["Answer"].focusAndType("Skiing")
        app.buttons["credentials.security-question.submit"].tap()

        XCTAssertTrue(app.alerts["app.error.generic.title"].waitForExistence())
        XCTAssertTrue(app.alerts.staticTexts["Test that we can parse an error"].waitForExistence())
    }

    private func login() {
        app.launch()

        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
    }
}
