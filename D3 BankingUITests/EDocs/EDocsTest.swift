//
//  EDocsTest.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 1/22/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class EDocsTest: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "EDocsL10n/edocs-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()

    // We need to specify these defaults so that snapshot and bio-auth enablement
    // does not show up post authentication while trying to run these tests.
    let overrideDefaultsRule: OverrideDefaultsRule = OverrideDefaultsRule(defaults: [
        .init(key: "performedSnapshotSetup", value: "1"),
        .init(key: "performedBiometricsSetup", value: "1")
    ])

    private let accountNames: [String] = [
        "My Deposit - Savings Account (••••••••••••4496)",
        "My Investment - Individual Retirement Account (ira) Account (••••••••••••5438)",
        "My Credit Card Account (••••••••••••3176)",
        "My Loan - Line Of Credit Account (••••••••••••4830)",
        "My Loan - Loan Account (••••••••••••4613)",
        "My Loan - Mortgage Account (••••••••••••2396)",
        "Deposit - Checking (•••••••••8948)",
        "Deposit - Checking (•••••••••7983)"
    ]

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

    // MARK: Prompt Appears

    /// This test tests that we get the edocs prompt when all edocs items are present
    /// i.e. GoPaperless, Estatements, Notices, and TaxDocs.
    func testGetEDocsPromptWhenEDocsAccountsArePresent() {
        // The json file specified here is a session that has all of the edocs present.
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        XCTAssert(promptAppears())
    }

    /// This test tests that we get the edocs prompt when only paperless accounts
    /// are present.
    func testGetEDocsPromptWhenOnlyPaperlessAccountsPresent() {
        // The json file specified here is a session that has only the GoPaperless accounts.
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-paperless.json")

        successfullyAuthenticate()

        XCTAssert(promptAppears())
    }

    /// This test tests that we get the edocs prompt when only estatements accounts
    /// are present.
    func testGetEDocsPromptWhenOnlyEstatementAccountsPresent() {
        // The json file specified here is a session that has only the Estatement accounts.
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-estatements.json")

        successfullyAuthenticate()

        XCTAssert(promptAppears())
    }

    /// This test tests that we get the edocs prompt when only notices
    /// are present.
    func testGetEDocsPromptWhenOnlyNoticesPresent() {
        // The json file specified here is a session that has only the notices accounts.
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-notices.json")

        successfullyAuthenticate()

        XCTAssert(promptAppears())
    }

    /// This test tests that we get the edocs prompt when only taxDocs
    /// is present.
    func testGetEDocsPromptWhenOnlyTaxDocsPresent() {
        // The json file specified here is a session that has only the tax docs.
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-tax.json")

        successfullyAuthenticate()

        XCTAssert(promptAppears())
    }

    // MARK: Account Selections Appear

    func testGoPaperlessAccountSelectionAppears() {
        proceedToGoPaperlessAccountSelection()
        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testEstatementsAccountSelectionsAppears() {
        proceedToEstatementsAccountSelection()
        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testNoticesAccountSelectionAppears() {
        proceedToNoticesAccountSelection()
        XCTAssert(noticesAccountSelectionAppears())
    }

    func testTaxDocsEnrollmentAppears() {
        proceedToTaxDocsEnrollment()
        XCTAssert(taxDocsEnrollmentAppears())
    }

    // MARK: Learn More

    /// This tests that the learn more view controller appears when
    /// touching the learn more button on the paperless prompt.
    func testLearnMoreAppearsWhenTouchingLearnMoreOnPrompt() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        app.buttons["edocs-prompt.learn-more.btn"].tap()

        XCTAssert(learnMoreAppears())
    }

    /// Tests that the prompt is shown again when the close button on the learn more view
    /// controller is touched.
    func testLearnMoreDismissesWhenCloseButtonTouched() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        app.buttons["edocs-prompt.learn-more.btn"].tap()

        XCTAssert(learnMoreAppears())

        app.buttons["edocs-prompt.learn-more.close"].tap()

        XCTAssert(promptAppears())
    }

    /// Tests to make sure that if the l10n is missing a question,
    /// or its associated answer, that neither the question or the answer are shown.
    func testQuestionsAndAnswersNotShownIfL10nValueIsEmpty() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        app.buttons["edocs-prompt.learn-more.btn"].tap()

        // The l10n file that is loaded has questions 4's value as empty
        // and answer 5's value as empty. When either the question or answer
        // is empty neither the question, nor the answer should be shown.
        XCTAssert(!app.staticTexts["Question 4"].waitForExistence())
        XCTAssert(!app.staticTexts["Answer 4"].waitForExistence())
        XCTAssert(!app.staticTexts["Question 5"].waitForExistence())
        XCTAssert(!app.staticTexts["Answer 5"].waitForExistence())
    }

    // MARK: Decline

    /// Tests that touching the decline button on the EDocs prompt proceeds to
    /// the dashboard without showing a confirmation page.
    func testPromptDeclineGoesToDashboard() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        app.buttons["edocs-prompt.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    /// Tests that touching decline on GoPaperless account selection takes the user
    /// to the dashboard.
    func testGoPaperlessAccountSelectionDeclineGoesToDashboard() {
        proceedToGoPaperlessAccountSelection()

        app.buttons["edocs-selection.estatements.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    /// Tests that touching decline on Estatement account selection takes the user
    /// to the dashboard.
    func testEstatementAccountSelectionDeclineGoesToDashboard() {
        proceedToEstatementsAccountSelection()

        app.buttons["edocs-selection.estatements.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    /// Tests that touching decline on Notices account selection takes the user
    /// to the dashboard.
    func testNoticesAccountSelectionDeclineGoesToDashboard() {
        proceedToNoticesAccountSelection()

        app.buttons["edocs-selection.notice.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    /// Tests that touching decline on tax docs selection takes the user
    /// to the dashboard.
    func testTaxDocsSelectionDeclineGoesToDashboard() {
        proceedToTaxDocsEnrollment()

        app.buttons["edocs-selection.tax.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    /// Tests that touching decline all selections takes the user
    /// to the dashboard.
    func testAllSelectionDeclinesGoesToDashboard() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()

        app.buttons["edocs-prompt.btn.yes"].tap()
        app.buttons["edocs-selection.estatements.btn.no"].tap()
        app.buttons["edocs-selection.estatements.btn.no"].tap()
        app.buttons["edocs-selection.notice.btn.no"].tap()
        app.buttons["edocs-selection.tax.btn.no"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    // MARK: Disclosures

    /// Tests that the disclosure for go paperless appears under the error condition
    /// (we have not given a route for the legal service)
    func testThatGoPaperlessDisclosureAppears() {
        openGoPaperlessDisclosure()

        XCTAssert(goPaperlessOrEstatementsDisclosureErrorIsShown())
    }

    /// Tests that when the disclosure is in an error state, touching the ok button
    /// on the alert dismisses the alert and the disclosure view controller.
    func testThatTouchingOkOnGoPaperlessDisclosureErrorDismissesTheDisclosure() {
        openGoPaperlessDisclosure()

        XCTAssert(goPaperlessOrEstatementsDisclosureErrorIsShown())

        app.alerts.buttons["app.alert.btn.ok"].tap()

        // We need to put the selection view controller back to the top
        // so that the appears check will find all of the things it is looking
        // for.
        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testThatTouchingOnGoPaperlessDisclosureShowsDisclosureInNonErrorState() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS_GO_PAPERLESS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openGoPaperlessDisclosure()

        XCTAssert(disclosureInNonErrorStateAppears())
    }

    func testDismissingGoPaperlessDisclosureWithCloseButton() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS_GO_PAPERLESS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openGoPaperlessDisclosure()

        let closeButtonIdentifier = "disclosure.btn.close.altText"
        let closeButton = app.buttons[closeButtonIdentifier]

        XCTAssert(
            closeButton.waitForExistence(),
            "Couldn't find button with identifier: \(closeButtonIdentifier)"
        )

        closeButton.tap()

        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testDismissingGoPaperlessDisclosureWithContinueButton() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS_GO_PAPERLESS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openGoPaperlessDisclosure()

        let continueButtonText = "disclosure.btn.continue.title"
        let continueButton = app.buttons[continueButtonText]

        XCTAssert(
            continueButton.waitForExistence(),
            "Couldn't find button with title: \(continueButtonText)"
        )

        continueButton.tap()

        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    /// Tests that the disclosure for estatements appears under the error condition
    /// (we have not given a route for the legal service)
    func testThatEstatementsDisclosureAppears() {
        openEstatementsDisclosure()

        XCTAssert(goPaperlessOrEstatementsDisclosureErrorIsShown())
    }

    /// Tests that when the disclosure is in an error state, touching the ok button
    /// on the alert dismisses the alert and the disclosure view controller.
    func testThatTouchingOkOnEstatementsDisclosureErrorDismissesTheDisclosure() {
        openEstatementsDisclosure()

        XCTAssert(goPaperlessOrEstatementsDisclosureErrorIsShown())

        app.alerts.buttons["app.alert.btn.ok"].tap()

        // We need to put the selection view controller back to the top
        // so that the appears check will find all of the things it is looking
        // for.
        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testThatTouchingOnEstatementsDisclosureShowsDisclosureInNonErrorState() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openEstatementsDisclosure()

        XCTAssert(disclosureInNonErrorStateAppears())
    }

    func testDismissingEstatementsDisclosureWithCloseButton() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openEstatementsDisclosure()

        let closeButtonIdentifier = "disclosure.btn.close.altText"
        let closeButton = app.buttons[closeButtonIdentifier]

        XCTAssert(
            closeButton.waitForExistence(),
            "Couldn't find the button with identifier: \(closeButtonIdentifier)"
        )

        closeButton.tap()

        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    func testDismissingEstatementsDisclosureWithContinueButton() {
        mockServerRule.get(
            "v3/content/legal/ACCTS_ESTATEMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openEstatementsDisclosure()

        let continueButtonText = "disclosure.btn.continue.title"
        let continueButton = app.buttons[continueButtonText]

        XCTAssert(
            continueButton.waitForExistence(),
            "Couldn't find button with text: \(continueButtonText)"
        )

        continueButton.tap()

        scrollToTop()

        XCTAssert(goPaperlessOrEstatementsAccountSelectionAppears())
    }

    /// Tests that the disclosure for notices appears under the error condition
    /// (we have not given a route for the legal service)
    func testThatNoticesDisclosureAppears() {
        openNoticesDisclosure()

        XCTAssert(noticesDisclosureErrorIsShown())
    }

    /// Tests that when the disclosure is in an error state, touching the ok button
    /// on the alert dismisses the alert and the disclosure view controller.
    func testThatTouchingOkOnNoticesDisclosureErrorDismissesTheDisclosure() {
        openNoticesDisclosure()

        XCTAssert(noticesDisclosureErrorIsShown())

        app.alerts.buttons["app.alert.btn.ok"].tap()

        // We need to put the selection view controller back to the top
        // so that the appears check will find all of the things it is looking
        // for.
        scrollToTop()

        XCTAssert(noticesAccountSelectionAppears())
    }

    func testThatTouchingOnNoticesDisclosureShowsDisclosureInNonErrorState() {
        mockServerRule.get(
            "v3/content/legal/E_ACCOUNT_NOTICE/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openNoticesDisclosure()

        XCTAssert(disclosureInNonErrorStateAppears())
    }

    func testDismissingNoticesDisclosureWithCloseButton() {
        mockServerRule.get(
            "v3/content/legal/E_ACCOUNT_NOTICE/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openNoticesDisclosure()

        let closeButtonIdentifier = "disclosure.btn.close.altText"
        let closeButton = app.buttons[closeButtonIdentifier]

        XCTAssert(
            closeButton.waitForExistence(),
            "Couldn't find button with identifier: \(closeButtonIdentifier)"
        )

        closeButton.tap()

        scrollToTop()

        XCTAssert(noticesAccountSelectionAppears())
    }

    func testDismissingNoticesDisclosureWithContinueButton() {
        mockServerRule.get(
            "v3/content/legal/E_ACCOUNT_NOTICE/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openNoticesDisclosure()

        let continueButtonText = "disclosure.btn.continue.title"
        let continueButton = app.buttons[continueButtonText]

        XCTAssert(
            continueButton.waitForExistence(),
            "Couldn't find button with title: \(continueButtonText)"
        )

        continueButton.tap()
        scrollToTop()

        XCTAssert(noticesAccountSelectionAppears())
    }

    /// Tests that the disclosure for tax docs appears under the error condition
    /// (we have not given a route for the legal service)
    func testThatTaxDocsDisclosureAppears() {
        openTaxDocsDisclosure()

        XCTAssert(taxDocsDisclosureErrorIsShown())
    }

    /// Tests that when the disclosure is in an error state, touching the ok button
    /// on the alert dismisses the alert and the disclosure view controller.
    func testThatTouchingOkOnTaxDocsDisclosureErrorDismissesTheDisclosure() {
        openTaxDocsDisclosure()

        XCTAssert(taxDocsDisclosureErrorIsShown())

        app.alerts.buttons["app.alert.btn.ok"].tap()

        // We need to put the selection view controller back to the top
        // so that the appears check will find all of the things it is looking
        // for.
        scrollToTop()

        XCTAssert(taxDocsEnrollmentAppears())
    }

    func testThatTouchingOnTaxDocsDisclosureShowsDisclosureInNonErrorState() {
        mockServerRule.get(
            "v3/content/legal/E_TAX_DOCUMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openTaxDocsDisclosure()

        XCTAssert(disclosureInNonErrorStateAppears())
    }

    func testDismissingTaxDocsDisclosureWithCloseButton() {
        mockServerRule.get(
            "v3/content/legal/E_TAX_DOCUMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openTaxDocsDisclosure()

        let closeButtonIdentifier = "disclosure.btn.close.altText"
        let closeButton = app.buttons[closeButtonIdentifier]

        XCTAssert(
            closeButton.waitForExistence(),
            "Couldn't find button with identifier: \(closeButtonIdentifier)"
        )

        closeButton.tap()
        scrollToTop()

        XCTAssert(taxDocsEnrollmentAppears())
    }

    func testDismissingTaxDocsDisclosureWithContinueButton() {
        mockServerRule.get(
            "v3/content/legal/E_TAX_DOCUMENTS/disclosure",
            jsonPath: "EDocsDisclosures/standard-disclosure.json"
        )

        openTaxDocsDisclosure()

        let continueButtonText = "disclosure.btn.continue.title"
        let continueButton = app.buttons[continueButtonText]

        XCTAssert(
            continueButton.waitForExistence(),
            "Couldn't find button with title: \(continueButtonText)"
        )

        continueButton.tap()
        scrollToTop()

        XCTAssert(taxDocsEnrollmentAppears())
    }

    // MARK: Confirmation

    func testConfirmationIsDisplayedWhenDecliningGoPaperlessOnly() {
        proceedToConfirmationPage(acceptingPromptsIn: [.estatements, .notices, .taxDocs])

        let table = app.tables.firstMatch
        XCTAssert(
            table.waitForExistence(),
            "The table never existed"
        )
        // Since we declined one of the prompts there should only be three cells on the
        // confirmation page. Four means that confirmation for declined selection appears
        XCTAssert(
            table.cells.count == 3,
            "Expected the number of cells to be 3, got: \(table.cells.count)"
        )

        let estatementsCell = table.cells.allElementsBoundByIndex[0]
        let noticesCell = table.cells.allElementsBoundByIndex[1]
        let taxDocsCell = table.cells.allElementsBoundByIndex[2]

        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: estatementsCell)
        checkConfirmationIsCorrectForNoticesFail(withCell: noticesCell)
        checkConfirmationIsCorrectForTaxDocsFail(withCell: taxDocsCell)
    }

    func testConfirmationIsDisplayedWhenDecliningEstatementsOnly() {
        proceedToConfirmationPage(acceptingPromptsIn: [.goPaperless, .notices, .taxDocs])

        let table = app.tables.firstMatch
        XCTAssert(
            table.waitForExistence(),
            "The table never existed"
        )

        XCTAssert(
            table.cells.count == 3,
            "Expected the number of cells to be 3, got: \(table.cells.count)"
        )

        let goPaperlessCell = table.cells.allElementsBoundByIndex[0]
        let noticesCell = table.cells.allElementsBoundByIndex[1]
        let taxDocsCell = table.cells.allElementsBoundByIndex[2]

        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: goPaperlessCell)
        checkConfirmationIsCorrectForNoticesFail(withCell: noticesCell)
        checkConfirmationIsCorrectForTaxDocsFail(withCell: taxDocsCell)
    }

    func testConfirmationIsDisplayedWhenDecliningNoticesOnly() {
        proceedToConfirmationPage(acceptingPromptsIn: [.goPaperless, .estatements, .taxDocs])

        let table = app.tables.firstMatch
        XCTAssert(
            table.waitForExistence(),
            "The table never existed"
        )

        XCTAssert(
            table.cells.count == 3,
            "Expected the number of cells to be 3, got: \(table.cells.count)"
        )

        let goPaperlessCell = table.cells.allElementsBoundByIndex[0]
        let estatementsCell = table.cells.allElementsBoundByIndex[1]
        let taxDocsCell = table.cells.allElementsBoundByIndex[2]

        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: goPaperlessCell)
        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: estatementsCell)
        checkConfirmationIsCorrectForTaxDocsFail(withCell: taxDocsCell)
    }

    func testConfirmationIsDisplayedWhenDecliningTaxDocsOnly() {
        proceedToConfirmationPage(acceptingPromptsIn: [.goPaperless, .estatements, .notices])

        let table = app.tables.firstMatch
         XCTAssert(
             table.waitForExistence(),
             "The table never existed"
         )

         XCTAssert(
             table.cells.count == 3,
             "Expected the number of cells to be 3, got: \(table.cells.count)"
         )

        let goPaperlessCell = table.cells.allElementsBoundByIndex[0]
        let estatementsCell = table.cells.allElementsBoundByIndex[1]
        let noticesCell = table.cells.allElementsBoundByIndex[2]

        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: goPaperlessCell)
        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell: estatementsCell)
        checkConfirmationIsCorrectForNoticesFail(withCell: noticesCell)
    }

    func testConfirmationIsDisplayedWhenAcceptingGoPaperlessAccounts() {
        proceedToConfirmationPageViaGoPaperless()

        XCTAssert(edocsConfirmationAppears())
    }

    /// Tests to ensure that when all fail only the failure results header (and accounts) are shown
    /// and not the sucess header (this is when the network fails).
    func testConfirmationPageShowsCorrectDataWhenGoPaperlessAccountsAreEnrolledAndAllFail() {
        proceedToConfirmationPageViaGoPaperless()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(
            withCell: app
                .tables
                .firstMatch
                .cells
                .allElementsBoundByIndex[0]
        )
    }
    
    /// This test confirms that with a mixed result, both successes and failures are shown in the
    /// results.
    func testConfimrationPageShowsCorrectDataWhenGoPaperlessAccountsAreEnrolledAndMixOfSuccessAndFailures() {
        // This response has a mix of success and failures so that both the success and failure results
        // headers should appear. The accounts in this response match the accounts in the successful
        // go paperless session in `EDocsSessions/session-edocs-paperless.json`
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )

        proceedToConfirmationPageViaGoPaperless()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementSuccessFailMix()
    }

    /// This test confirms that with a mixed result, both successes and failures are shown in the
    /// results.
    func testConfimrationPageShowsCorrectDataWhenGoPaperlessAccountsAreEnrolledAndAllSucceed() {
        // This response contains all successes so that both only the success result
        // header should appear. The accounts in this response match the accounts in the successful
        // go paperless session in `EDocsSessions/session-edocs-paperless.json`
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )
        
        proceedToConfirmationPageViaGoPaperless()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementsWhenAllSucceed()
    }

    func testConfirmationIsDisplayedWhenAcceptingEstatementAccounts() {
        proceedToEstatementsAccountSelection()

        app.buttons["edocs-selection.estatements.btn.yes"].tap()

        XCTAssert(edocsConfirmationAppears())
    }

    /// Tests to ensure that when all fail only the failure results header (and accounts) are shown
    /// and not the sucess header (this is when the network fails).
    func testConfirmationPageShowsCorrectDataWhenEstatementAccountsAreEnrolledAndAllFail() {
        proceedToConfirmationPageViaEstatements()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(
            withCell: app
                .tables
                .firstMatch
                .cells
                .allElementsBoundByIndex[0]
        )
    }

    /// This test confirms that with a mixed result, both successes and failures are shown in the
    /// results.
    func testConfimrationPageShowsCorrectDataWhenEstatementAccountsAreEnrolledAndMixOfSuccessAndFailures() {
        // This response has a mix of success and failures so that both the success and failure results
        // headers should appear. The accounts in this response match the accounts in the successful
        // estatements session in `EDocsSessions/session-edocs-estatements.json`
        //
        // Note: We can use the same json file that we use for go paperless since the prompt accounts format
        // is the same and the accounts match in `EDocsSessions/session-edocs-estatements.json`
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )

        proceedToConfirmationPageViaEstatements()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementSuccessFailMix()
    }

    /// This test confirms that with a mixed result, both successes and failures are shown in the
    /// results.
    func testConfimrationPageShowsCorrectDataWhenEstatementsAccountsAreEnrolledAndAllSucceed() {
        // This response contains all successes so that both only the success result
        // header should appear. The accounts in this response match the accounts in the successful
        // estatments session in `EDocsSessions/session-edocs-estatements.json`
        //
        // Note: We can use the same json file that we use for go paperless since the prompt accounts format
        // is the same and the accounts match in `EDocsSessions/session-edocs-estatements.json`
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )

        proceedToConfirmationPageViaEstatements()
        checkConfirmationIsCorrectForGoPaperlessAndEstatementsWhenAllSucceed()
    }

    func testConfirmationIsDisplayedWhenAcceptingNoticeAccounts() {
        proceedToConfirmationPageViaNotices()

        XCTAssert(
            edocsConfirmationAppears(),
            "EDocs confirmation screen never appeared."
        )
    }

    /// Tests whether all of the notices failed when having a network error. The notice accounts
    /// here are those found in the `EDocsSessions/session-edocs-notices.json`
    func testConfirmationPageShowsCorrectDataWhenNoticesAccountsAreEnrolledAndNetworkFails() {
        proceedToConfirmationPageViaNotices()
        checkConfirmationIsCorrectForNoticesFail(
            withCell: app
                .tables
                .firstMatch
                .cells
                .allElementsBoundByIndex[0]
        )
    }

    /// Tests whether all of the notices succeeded when having a network success. The notice accounts
    /// here are those found in the `EDocsSessions/session-edocs-notices.json`
    func testConfirmationPageShowsCorrectDataWhenNoticesAccountsAreEnrolledAndNetworkSucceeds() {
        // We are only concerned with a networ success or failure here so the
        // `EDocsNetworkResponses/"notices-and-tax-success.json"` file is essentially an empty
        // json response.
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )

        proceedToConfirmationPageViaNotices()

        let noticesResultCell = app
            .tables
            .firstMatch
            .cells
            .allElementsBoundByIndex[0]

        XCTAssert(
            noticesResultCell.staticTexts["edocs-result.notice.header"].waitForExistence(),
            "Did not find notices result header."
        )

        XCTAssert(
            !noticesResultCell.staticTexts["edocs-result.notice.failure"].exists,
            "Found failure result header"
        )

        XCTAssert(
            noticesResultCell.staticTexts["edocs-result.notice.success"].waitForExistence(),
            "Did not find success result header"
        )

        accountNames.forEach { name in
            XCTAssert(
                noticesResultCell.staticTexts[name].waitForExistence(),
                "Did not find account: \(name)"
            )
        }
    }

    func testConfirmationIsDisplayedWhenAcceptingTaxDocs() {
        proceedToConfirmationPageViaTaxDocs()

        XCTAssert(
            edocsConfirmationAppears(),
            "EDocs confirmation screen never appeared."
        )
    }

    /// Tests the failure when of enrolling in tax docs (network error).
    func testConfirmationPageShowsCorrectDataWhenTaxDocsAreEnrolledAndNetworkFails() {
        proceedToConfirmationPageViaTaxDocs()
        checkConfirmationIsCorrectForTaxDocsFail(
            withCell: app
                .tables
                .firstMatch
                .cells
                .allElementsBoundByIndex[0]
        )
    }

    func testConfirmationPageShowsCorrectDataWhenTaxDocsAreEnrolledAndSuccess() {
        mockServerRule.put(
            "/v4/edocs/preferences",
            jsonPath: "EDocsNetworkResponses/notices-and-tax-success.json"
        )

        proceedToConfirmationPageViaTaxDocs()

        let taxDocsResultCell = app
            .tables
            .firstMatch
            .cells
            .allElementsBoundByIndex[0]

        XCTAssert(
            taxDocsResultCell.staticTexts["edocs-result.tax.header"].waitForExistence(),
            "Did not find tax docs result header."
        )

        XCTAssert(
            !taxDocsResultCell.staticTexts["edocs-result.tax.failure"].exists,
            "Did not find failure result header"
        )

        XCTAssert(
            taxDocsResultCell.staticTexts["edocs-result.tax.success"].waitForExistence(),
            "Found success result header"
        )
    }

    func testTouchingSubmitButtonOnConfirmationGoesToDashboard() {
        proceedToConfirmationPageViaGoPaperless()

        app.buttons["edocs-result.btn.done"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    // MARK: Helpers

    private struct PromptsToAccept: OptionSet {
        var rawValue: UInt8

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        static let goPaperless = PromptsToAccept(rawValue: 1 << 0)
        static let estatements = PromptsToAccept(rawValue: 1 << 1)
        static let notices = PromptsToAccept(rawValue: 1 << 2)
        static let taxDocs = PromptsToAccept(rawValue: 1 << 3)
    }

    private func successfullyAuthenticate() {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }

        app.launch()

        let usernameField = app.textFields["Enter user name"]
        XCTAssert(usernameField.waitForExistence())
        usernameField.focusAndType("samualadamsiii")

        let passwordField = app.secureTextFields["Enter password"]
        XCTAssert(passwordField.waitForExistence())
        passwordField.focusAndType("password")

        let submitButton = app.buttons["Submit"]
        XCTAssert(submitButton.waitForExistence())
        submitButton.tap()
    }

    private func proceedToGoPaperlessAccountSelection() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-paperless.json")
        authenticateAndAcceptPrompt()
    }

    private func proceedToEstatementsAccountSelection() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-estatements.json")
        authenticateAndAcceptPrompt()
    }

    private func proceedToNoticesAccountSelection() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-notices.json")
        authenticateAndAcceptPrompt()
    }

    private func proceedToTaxDocsEnrollment() {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-tax.json")
        authenticateAndAcceptPrompt()
    }

    private func proceedToConfirmationPageViaGoPaperless() {
        proceedToGoPaperlessAccountSelection()
        acceptGoPaperlessOrEstatementsAccountSelection()
    }

    private func proceedToConfirmationPageViaEstatements() {
        proceedToEstatementsAccountSelection()
        acceptGoPaperlessOrEstatementsAccountSelection()
    }

    private func proceedToConfirmationPageViaNotices() {
        proceedToNoticesAccountSelection()

        // This assumes that the company attribute "accounts.notices.default.enabled" is
        // enabled (set to true) in the CommonData/standard-startup/startup/ui.json file. If this
        // attribute is changed to false, the select all checkbox, or at least one account, will need
        // to be manually selected before the submit button is enabled.
        let noticesSubmitButtonText = "edocs-selection.notice.btn.yes"
        let noticesSubmitButton = app.buttons[noticesSubmitButtonText]

        XCTAssert(
            noticesSubmitButton.waitForExistence(),
            "Couldn't find button with title \(noticesSubmitButtonText) after waiting for existence."
        )

        noticesSubmitButton.tap()
    }

    private func proceedToConfirmationPageViaTaxDocs() {
        proceedToTaxDocsEnrollment()

        // This assumes that the company attribute "user.etaxDocument.default.enabled" is
        // enabled (set to true) in the CommonData/standard-startup/startup/ui.json file. If this
        // attribute is changed to false, the enroll in tax docs checkbox, will need
        // to be manually selected before the submit button is enabled.
        let taxDocsSubmitButtonText = "edocs-selection.tax.btn.yes"
        let taxDocsSubmitButton = app.buttons[taxDocsSubmitButtonText]

        XCTAssert(
            taxDocsSubmitButton.waitForExistence(),
            "Couldn't find button with title \(taxDocsSubmitButtonText) after waiting for existence."
        )

        taxDocsSubmitButton.tap()
    }

    private func proceedToConfirmationPage(acceptingPromptsIn promptsToAccept: PromptsToAccept) {
        mockServerRule.get("/auth/session", jsonPath: "EDocsSessions/session-edocs-all.json")

        successfullyAuthenticate()
        app.buttons["edocs-prompt.btn.yes"].tap()

        // At this point since we are getting `EDocsSessions/session-edocs-all.json` we
        // know that we must walk through each of the account selections
        if promptsToAccept.contains(.goPaperless) {
            app.buttons["edocs-selection.estatements.btn.yes"].tap()
        } else {
            app.buttons["edocs-selection.estatements.btn.no"].tap()
        }

        if promptsToAccept.contains(.estatements) {
            app.buttons["edocs-selection.estatements.btn.yes"].tap()
        } else {
            app.buttons["edocs-selection.estatements.btn.no"].tap()
        }

        if promptsToAccept.contains(.notices) {
            app.buttons["edocs-selection.notice.btn.yes"].tap()
        } else {
            app.buttons["edocs-selection.notice.btn.no"].tap()
        }

        if promptsToAccept.contains(.taxDocs) {
            app.buttons["edocs-selection.tax.btn.yes"].tap()
        } else {
            app.buttons["edocs-selection.tax.btn.no"].tap()
        }
    }

    private func acceptGoPaperlessOrEstatementsAccountSelection() {
        XCTAssert(app.buttons["edocs-selection.estatements.btn.yes"].waitForExistence())
        app.buttons["edocs-selection.estatements.btn.yes"].tap()
    }

    private func authenticateAndAcceptPrompt() {
        successfullyAuthenticate()

        let promptSubmitButtonText = "edocs-prompt.btn.yes"
        let promptSubmitButton = app.buttons[promptSubmitButtonText]

        XCTAssert(
            promptSubmitButton.waitForExistence(),
            "Couldn't find the button with title: \(promptSubmitButtonText)"
        )

        promptSubmitButton.tap()
    }

    private func promptAppears() -> Bool {
        return app.staticTexts["edocs-prompt.ability.title"].waitForExistence()
            && app.staticTexts["edocs-prompt.why.text"].waitForExistence()
            && app.buttons["edocs-prompt.btn.yes"].waitForExistence()
            && app.buttons["edocs-prompt.btn.no"].waitForExistence()
            && app.buttons["edocs-prompt.learn-more.btn"].waitForExistence()
    }

    private func learnMoreAppears() -> Bool {
        return app.staticTexts["edocs-prompt.learn-more.page-title"].waitForExistence()
            && app.buttons["edocs-prompt.learn-more.close"].waitForExistence()
            && app.staticTexts["Question 1"].waitForExistence()
            && app.staticTexts["Answer 1"].waitForExistence()
            && app.staticTexts["Question 2"].waitForExistence()
            && app.staticTexts["Answer 2"].waitForExistence()
            && app.staticTexts["Question 3"].waitForExistence()
            && app.staticTexts["Answer 3"].waitForExistence()
    }

    private func goPaperlessOrEstatementsAccountSelectionAppears() -> Bool {
        return app.staticTexts["edocs-selection.estatements.title"].waitForExistence()
            && app.staticTexts["edocs-selection.estatements.info.text"].waitForExistence()
            && app.buttons["edocs-selection.estatements.btn.select-all"].waitForExistence()
            && app.buttons["edocs-selection.estatements.btn.yes"].waitForExistence()
            && app.buttons["edocs-selection.estatements.btn.no"].waitForExistence()
            && hasDisclosureButton(withTitle: "edocs-selection.estatements.btn.view-disclosure")
    }

    private func noticesAccountSelectionAppears() -> Bool {
        return app.staticTexts["edocs-selection.notice.title"].waitForExistence()
            && app.staticTexts["edocs-selection.notice.info.text"].waitForExistence()
            && app.buttons["edocs-selection.notice.btn.select-all"].waitForExistence()
            && app.buttons["edocs-selection.notice.btn.yes"].waitForExistence()
            && app.buttons["edocs-selection.notice.btn.no"].waitForExistence()
            && hasDisclosureButton(withTitle: "edocs-selection.notice.btn.view-disclosure")
    }

    private func taxDocsEnrollmentAppears() -> Bool {
        return app.staticTexts["edocs-selection.tax.title"].waitForExistence()
            && app.staticTexts["edocs-selection.tax.info.text"].waitForExistence()
            && app.buttons["edocs-selection.tax.checkbox"].waitForExistence()
            && app.buttons["edocs-selection.tax.btn.yes"].waitForExistence()
            && app.buttons["edocs-selection.tax.btn.no"].waitForExistence()
            && hasDisclosureButton(withTitle: "edocs-selection.tax.btn.view-disclosure")
    }

    private func edocsConfirmationAppears() -> Bool {
        return app.staticTexts["edocs-result.title"].waitForExistence()
            && app.staticTexts["edocs-result.subtitle"].waitForExistence()
            && app.buttons["edocs-result.btn.done"].waitForExistence()
            && hasConfirmationInfoFooter()
    }

    private func disclosureInNonErrorStateAppears() -> Bool {
        return app.staticTexts["This is a disclosure"].waitForExistence(timeout: 30)
            && app.buttons["disclosure.btn.continue.title"].waitForExistence()
            && app.buttons["disclosure.btn.close.altText"].waitForExistence()
    }

    private func hasDisclosureButton(withTitle title: String) -> Bool {
        // We need to make sure that the disclosure button is
        // on screen before we assert that it exists. To do this
        // we first scroll to it.
        scrollToBottom()

        return app.buttons[title].waitForExistence()
    }

    private func hasConfirmationInfoFooter() -> Bool {
        scrollToBottom()

        return app.staticTexts["edocs-result.info"].waitForExistence()
    }

    private func openGoPaperlessDisclosure() {
        proceedToGoPaperlessAccountSelection()
        touchDisclosureButton(withTitle: "edocs-selection.estatements.btn.view-disclosure")
    }

    private func openEstatementsDisclosure() {
        proceedToEstatementsAccountSelection()
        touchDisclosureButton(withTitle: "edocs-selection.estatements.btn.view-disclosure")
    }

    private func openNoticesDisclosure() {
        proceedToNoticesAccountSelection()
        touchDisclosureButton(withTitle: "edocs-selection.notice.btn.view-disclosure")
    }

    private func openTaxDocsDisclosure() {
        proceedToTaxDocsEnrollment()
        touchDisclosureButton(withTitle: "edocs-selection.tax.btn.view-disclosure")
    }

    private func touchDisclosureButton(withTitle title: String) {
        scrollToBottom()

        let button = app.buttons[title]

        XCTAssert(
            button.waitForExistence(),
            "Couldn't find button with title: \(title)"
        )

        button.tap()

        // This is here so that the disclosure has time to fully load
        // it is not ideal but it is a work around for the
        // `Failed to get matching snapshots: Error getting main window kAXErrorServerNotFound`
        // there is very little in the way of explaining why this happens and this workaround was
        // suggested here: https://github.com/mapbox/ios-sdk-examples/issues/358#issuecomment-574556863
        Thread.sleep(forTimeInterval: 2)
    }

    private func touchGoPaperlessOrEstatementsDisclosureButton() {
        let disclosureButtonTitle = "edocs-selection.estatements.btn.view-disclosure"

        scrollToBottom()
        app.buttons[disclosureButtonTitle].tap()
    }

    private func goPaperlessOrEstatementsDisclosureErrorIsShown() -> Bool {
        let alert = app.alerts.firstMatch

        return alert.waitForExistence()
            && app.alerts.staticTexts["app.error.generic.title"].waitForExistence()
            && app.alerts.staticTexts["edocs-selection.estatements.disclosure.error"].waitForExistence()
            && app.alerts.buttons["app.alert.btn.ok"].waitForExistence()
    }

    private func noticesDisclosureErrorIsShown() -> Bool {
        let alert = app.alerts.firstMatch

        return alert.waitForExistence()
            && alert.staticTexts["app.error.generic.title"].waitForExistence()
            && alert.staticTexts["edocs-selection.notice.disclosure.error"].waitForExistence()
            && alert.buttons["app.alert.btn.ok"].waitForExistence()
    }

    private func taxDocsDisclosureErrorIsShown() -> Bool {
        let alert = app.alerts.firstMatch

        return alert.waitForExistence()
            && alert.staticTexts["app.error.generic.title"].waitForExistence()
            && alert.staticTexts["edocs-selection.tax.disclosure.error"].waitForExistence()
            && alert.buttons["app.alert.btn.ok"].waitForExistence()
    }

    private func scrollToBottom() {
        let tableView = app.tables.element(boundBy: 0).firstMatch
        let lastCell = tableView.cells.allElementsBoundByIndex.last

        while !(lastCell?.isHittable ?? true) {
            app.swipeUp()
        }
    }

    private func scrollToTop() {
        let tableView = app.tables.element(boundBy: 0).firstMatch
        let firstCell = tableView.cells.allElementsBoundByIndex.first

        while !(firstCell?.isHittable ?? true) {
            app.swipeDown()
        }
    }

    private func checkConfirmationIsCorrectForGoPaperlessAndEstatementFail(withCell cell: XCUIElement) {
        // Ensure that Go Paperless results cell is present.
        XCTAssert(
            cell.staticTexts["edocs-result.estatements.header"].waitForExistence(),
            "Did not find the go paperless result header"
        )

        // Make sure that the failures stack has the correct header
        XCTAssert(
            cell.staticTexts["edocs-result.estatements.failure"].waitForExistence(),
            "Did not find the failure results header"
        )

        // Make sure that all of the accounts that should be present are present
        // These accounts come from the paperless accounts in the `session-edocs-paperless.json` file.
        accountNames.forEach { name in
            XCTAssert(
                cell.staticTexts[name].waitForExistence(),
                "Did not find account: \(name)"
            )
        }
    }

    private func checkConfirmationIsCorrectForNoticesFail(withCell cell: XCUIElement) {
        XCTAssert(
            cell.staticTexts["edocs-result.notice.header"].waitForExistence(),
            "Did not find notices result header."
        )

        XCTAssert(
            cell.staticTexts["edocs-result.notice.failure"].waitForExistence(),
            "Did not find failure result header"
        )

        XCTAssert(
            !cell.staticTexts["edocs-result.notices.success"].exists,
            "Found success result header"
        )

        accountNames.forEach { name in
            XCTAssert(
                cell.staticTexts[name].waitForExistence(),
                "Did not find account: \(name)"
            )
        }
    }

    private func checkConfirmationIsCorrectForTaxDocsFail(withCell cell: XCUIElement) {
        XCTAssert(
            cell.staticTexts["edocs-result.tax.header"].waitForExistence(),
            "Did not find tax docs result header."
        )

        XCTAssert(
            cell.staticTexts["edocs-result.tax.failure"].waitForExistence(),
            "Did not find failure result header"
        )

        XCTAssert(
            !cell.staticTexts["edocs-result.tax.success"].exists,
            "Found success result header"
        )
    }

    private func checkConfirmationIsCorrectForGoPaperlessAndEstatementSuccessFailMix() {
        let goPaperlessResultCell = app
            .tables
            .firstMatch
            .cells
            .allElementsBoundByIndex[0]

        XCTAssert(
            goPaperlessResultCell.staticTexts["edocs-result.estatements.header"].waitForExistence(),
            "Did not find the go paperless result header"
        )

        XCTAssert(
            goPaperlessResultCell.staticTexts["edocs-result.estatements.success"].waitForExistence(),
            "Did not find the go paperless success results header"
        )
        
        XCTAssert(
            !goPaperlessResultCell.staticTexts["edocs-result.estatements.failure"].waitForExistence(),
            "Did not find the go paperless success results header"
        )

        // Make sure that all of the accounts that should be present are present
        // These accounts come from the paperless accounts in the `session-edocs-paperless.json` file.
        accountNames.forEach { name in
            XCTAssert(
                goPaperlessResultCell.staticTexts[name].waitForExistence(),
                "Did not find account: \(name)"
            )
        }
    }

    private func checkConfirmationIsCorrectForGoPaperlessAndEstatementsWhenAllSucceed() {
        let goPaperlessResultCell = app
            .tables
            .firstMatch
            .cells
            .allElementsBoundByIndex[0]

        XCTAssert(
            goPaperlessResultCell.staticTexts["edocs-result.estatements.header"].waitForExistence(),
            "Did not find the go paperless result header"
        )

        XCTAssert(
            !goPaperlessResultCell.staticTexts["edocs-result.estatements.failure"].exists,
            "Found go paperless failure and shouldn't have."
        )

        XCTAssert(
            goPaperlessResultCell.staticTexts["edocs-result.estatements.success"].waitForExistence(),
            "Did not find the go paperless success results header"
        )

        // Make sure that all of the accounts that should be present are present
        // These accounts come from the paperless accounts in the `session-edocs-paperless.json` file.
        accountNames.forEach { name in
            XCTAssert(
                goPaperlessResultCell.staticTexts[name].waitForExistence(),
                "Did not find account: \(name)"
            )
        }
    }
}
