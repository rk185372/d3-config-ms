//
//  OutofBandTests.swift
//  D3 BankingUITests
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 2/23/21.
//

import Foundation
import XCTest

final class OutofBandTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")

    // let oobLocalizableRule:
    
    override func setUp() {
        super.setUp()
        
        mockServerRule.prefix(jsonPath: "CommonData/standard-startup") { router in
            router.prefix(path: "/startup", jsonPath: "/startup", router: { router in
                router.get("/ui", jsonPath: "/ui-oob-reset.json")
                router.get("/mobile-initialization", jsonPath: "/mobile-initialization.json")
            })
            router.get("/view/quick", jsonPath: "/view/quick.json")
        }
    }
    
    private func login() {
        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()
    }
    
    func testEnsurePrimaryUserDisplayed() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/primary-user-not-repeat-contact.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertFalse(app.staticTexts["Additional email"].exists)
        XCTAssertFalse(app.textFields["Enter an additional email"].exists)
        XCTAssertFalse(app.staticTexts["Additional phone"].exists)
        XCTAssertFalse(app.textFields["Enter an additional phone"].exists)
    }
    
    func testEnsurePrimaryUserDisplayedWithContactEmailAndPhoneRepeat() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/primary-user-repeat-contact.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertTrue(app.staticTexts["Additional email"].waitForExistence())
        XCTAssertTrue(app.textFields["Enter an additional email"].waitForExistence())
        XCTAssertTrue(app.staticTexts["Additional phone"].waitForExistence())
        XCTAssertTrue(app.textFields["Enter an additional mobile phone"].waitForExistence())
    }
    
    func testEnsurePrimaryUserDisplayedNotRepeatNotCompletContact() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/primary-user-not-repeatble-not-complete-contact.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertTrue(app.staticTexts["Additional email"].exists)
        XCTAssertTrue(app.textFields["Enter an additional email"].exists)
        XCTAssertFalse(app.staticTexts["Additional phone"].exists)
        XCTAssertFalse(app.textFields["Enter an additional mobile phone"].exists)
    }
    
    func testEnsurePrimaryUserDisplayedValidateMaxEmailAddress() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/primary-user-max-email-reached.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertFalse(app.staticTexts["Additional email"].exists)
        XCTAssertFalse(app.textFields["Enter an additional email"].exists)
        XCTAssertFalse(app.staticTexts["Additional phone"].exists)
        XCTAssertFalse(app.textFields["Enter an additional mobile phone"].exists)
    }
    
    func testEnsureSecondaryUserProfileNoEmailAddressEntryText() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/secondary-userprofile.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertFalse(app.staticTexts["Additional email"].exists)
        XCTAssertFalse(app.textFields["Enter an additional email"].exists)
        XCTAssertFalse(app.staticTexts["Additional phone"].exists)
        XCTAssertFalse(app.textFields["Enter an additional mobile phone"].exists)
    }
    
    func testEnsureSecondaryUserProfileNoMobile() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated.json")
        }

        mockServerRule.prefix(path: "/auth/session", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/secondary-userprofile-nomobile.json")
        }
        
        mockServerRule.prefix(path: "/users/setup", jsonPath: "post-authentication") { router in
            router.get("", jsonPath: "/security-questions.json")
            router.post("", jsonPath: "/security-answers.json")
        }
        app.launch()

        login()
        
        XCTAssertTrue(app.staticTexts["Setup of Security Verifications"].waitForExistence())
        XCTAssertTrue(app.staticTexts["For the additional security of our digital banking users..."].waitForExistence())
        XCTAssertFalse(app.staticTexts["Additional email"].exists)
        XCTAssertFalse(app.textFields["Enter an additional email"].exists)
        XCTAssertTrue(app.staticTexts["Additional phone"].exists)
        XCTAssertTrue(app.textFields["Enter an additional mobile phone"].exists)
    }
}
