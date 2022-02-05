//
//  RDCTests.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 2/17/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class RDCTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "authentication/authentication-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()
    let providesMockRDCImagesRule = ProvidesMockRDCImages()
    let overrideDefaultsRule: OverrideDefaultsRule = OverrideDefaultsRule(defaults: [
        .init(key: "performedSnapshotSetup", value: "1"),
        .init(key: "performedBiometricsSetup", value: "1")
    ])

    // We are adding a '$' to the end because underneath,
    // this path will be made into a regex and we want this
    // to match then end of the search path i.e. we don't
    // want it to match both "/v4/deposits" and "/v4/deposits/rdc"
    private let depositsHistoryPath: String = "/v4/deposits$"
    private let depositSubmitPath: String = "/v4/deposits$"
    private let depositAccountsPath: String = "/v4/deposits/rdc$"

    private let existsPredicate: NSPredicate = {
        return NSPredicate(format: "exists == %d", 1)
    }()

    private let doesNotExistPredicate: NSPredicate = {
        return NSPredicate(format: "exists == %d", 0)
    }()

    private let isHittablePredicate: NSPredicate = {
        return NSPredicate(format: "isHittable == %d", 1)
    }()

    override func setUp() {
        super.setUp()

        mockServerRule.get(
            "/v3/startup/mobile-initialization",
            jsonPath: "CommonData/standard-startup/startup/mobile-initialization.json"
        )

        mockServerRule.get(
            "/view/quick",
            jsonPath: "CommonData/standard-startup/view/quick.json"
        )
    }

    // MARK: RDC Appears

    func testNoRDCWhenSessionDoesNotHaveRDCAllowed() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "CommonData/standard-startup/startup/ui.json")

        proceedToDashboard(rdcAllowed: false)

        let tabBar = app.tabBars.firstMatch

        // Ensure that there is no RDC tab bar item immediately available.
        XCTAssert(!tabBar.buttons["RDC"].exists)

        // We also need to make sure that if there is a more menu. RDC is not available
        // there either.
        if tabBar.buttons["More"].waitForExistence() {
            tabBar.buttons["More"].tap()
            XCTAssert(!app.staticTexts["RDC"].exists)
        }
    }

    func testRDCIsPresentWhenRDCAllowed() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "CommonData/standard-startup/startup/ui.json")

        proceedToDashboard()

        let tabBar = app.tabBars.firstMatch

        if tabBar.buttons["RDC"].waitForExistence() {
            XCTAssert(true)
        } else if tabBar.buttons["More"].waitForExistence() {
            tabBar.buttons["More"].tap()
            XCTAssert(app.staticTexts["RDC"].waitForExistence())
        } else {
            XCTAssert(false, "No RDC item was found.")
        }
    }

    // MARK: History or Landing Page

    func testUserIsTakenToDepositLandingPageWhenHistoryDisabled() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "RDCStartup/rdc-startup-ui-history-disabled.json")

        proceedToDashboard()
        openRDC()

        XCTAssert(depositLandingPageAppears(), "Deposit landing page did not appear.")
    }

    func testUserIsTakenToHistoryPageWhenHistoryEnabled() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "RDCStartup/rdc-startup-ui-history-enabled.json")

        proceedToDashboard()
        openRDC()

        waitForHistoryPageToAppear()
    }

    // MARK: RDC History

    func testTryAgainButtonOnHistoryIsShownWhenHistoryFailsToLoad() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "RDCStartup/rdc-startup-ui-history-enabled.json")

        proceedToDashboard()
        openRDC()

        XCTAssert(
            app.staticTexts["dashboard.widget.deposit.history.error.title"].waitForExistence(),
            "Did failure to load error message."
        )

        XCTAssert(
            app.buttons["Try Again"].waitForExistence(),
            "Did not find try again button."
        )
    }

    func testTryAgainButtonRetriesHistory() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "RDCStartup/rdc-startup-ui-history-enabled.json")

        proceedToDashboard()
        openRDC()

        let table = app.tables.firstMatch
        let tryAgainButton = app.buttons["Try Again"]
        XCTAssert(tryAgainButton.waitForExistence())

        // We haven't overriden the history network call yet, so it should return an error.
        // This will give us the try again button which, we will touch after we override the
        // network to give a successful response.
        mockServerRule.get(depositsHistoryPath, jsonPath: "RDCResponses/rdc-history-response.json")
        tryAgainButton.tap()

        // Check to make sure that the two history items from the response above are present.
        // The first two cells in the table view are for the deposit a check button and the deposit
        // delay message. Thus, we expect there to be four cells with cells at indicies two and three
        // being the two history items.
        let numberOfCells = table.cells.count
        XCTAssert(
            numberOfCells == 4,
            "Expected four cells, got: \(numberOfCells)"
        )

        let item1 = table.cells.allElementsBoundByIndex[2]
        let item2 = table.cells.allElementsBoundByIndex[3]

        XCTAssert(
            item1.staticTexts["SUBMITTED"].waitForExistence()
                && item1.staticTexts["$50.00"].waitForExistence()
        )

        XCTAssert(
            item2.staticTexts["SUBMITTED"].waitForExistence()
                && item2.staticTexts["$75.00"].waitForExistence()
        )
    }

    // MARK: Deposit Details

    func testDepositDetailsDisplaysWhenTouchingAHistoryItem() {
        mockServerRule.get("/v3/startup/ui", jsonPath: "RDCStartup/rdc-startup-ui-history-enabled.json")
        mockServerRule.get(depositsHistoryPath, jsonPath: "RDCResponses/rdc-history-response.json")

        proceedToDashboard()
        openRDC()

        // We are going to assume that the history item exists and access it directly
        app.tables.firstMatch.cells.allElementsBoundByIndex[2].tap()

        waitForDepositDetailsPageToExist()

        // Because we waited for the details page to exist we know that the
        // details page back button should now exist so we go ahead and tap
        // it directly
        app.buttons["dashboard.widget.deposit.history.title"].tap()

        waitForHistoryPageToAppear()
    }

    // MARK: Close

    func testCloseButtonExitsRDCFlowAndReturnsToHistoryWhenHistoryEnabled() {
        proceedToDepositFlow()

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence(), "Did not find close button")
        closeButton.tap()

        waitForHistoryPageToAppear()
    }

    func testCloseButtonExitsRDCFlowAndReturnsToLandingPageWhenHistoryDisabled() {
        proceedToDepositFlow(historyEnabled: false)

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence(), "Did not find close button")
        closeButton.tap()

        XCTAssert(depositLandingPageAppears(), "Deposit landing page did not appear.")
    }

    func testCloseButtonOnDepositViewControllerShowsWarningAlertIfAnyInformationWasAdded() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence())

        let amountTextField = app.textFields["deposit-amount-textField"]
        amountTextField.focusAndType("1")
        app.buttons["Done"].tap()
        closeButton.tap()

        waitForAreYouSureAlertToAppear()
    }

    func testThatAreYouSureAlertDismissesWhenTouchingCancelButton() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence())

        let amountTextField = app.textFields["deposit-amount-textField"]
        amountTextField.focusAndType("1")
        app.buttons["Done"].tap()
        closeButton.tap()

        // Tests to make sure the alert is present
        waitForAreYouSureAlertToAppear()

        app.alerts.firstMatch.buttons["app.alert.btn.cancel"].tap()

        // Tests to make sure the alert has been dismissed.
        XCTAssert(!app.alerts.firstMatch.exists)
    }

    func testOkOnAreYouSureAlertReturnsUserToHistoryWhenHistoryIsEnabled() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence())

        let amountTextField = app.textFields["deposit-amount-textField"]
        amountTextField.focusAndType("1")
        app.buttons["Done"].tap()
        closeButton.tap()
        waitForAreYouSureAlertToAppear()
        app.alerts.firstMatch.buttons["app.alert.btn.ok"].tap()

        waitForDepositPageToNotExist()

        // The history page will still have been in the view hierarchy since the deposit
        // flow will have been presented modally. Because of this, it is not enough to
        // check that it is there, we also want to see that it is hittable (in view)
        // when the user has dismissed the deposit flow via the are-you-sure alert.
        waitForHistoryPageToAppear()
        waitForHistoryPageToBeHittable()
    }

    func testOkOnAreYouSureAlertReturnsUserToDepositLandingPageWhenHistoryIsDisabled() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow(historyEnabled: false)

        let closeButton = app.buttons["rdc-deposit-controller-close-button"]
        XCTAssert(closeButton.waitForExistence())

        let amountTextField = app.textFields["deposit-amount-textField"]
        amountTextField.focusAndType("1")
        app.buttons["Done"].tap()
        closeButton.tap()
        
        waitForAreYouSureAlertToAppear()
        app.alerts.firstMatch.buttons["app.alert.btn.ok"].tap()

        waitForDepositPageToNotExist()

        XCTAssert(depositLandingPageAppears())

        waitForLandingPageToBeHittable()
    }

    // MARK: Deposit View

    func testTryAgainAppearsWhenDepositsFailToLoad() {
        proceedToDepositFlow()

        // We have not set a path for a successful deposit accounts network response, so we expect
        // the page to fail to load. In this case, we expect a try again button to be present.
        XCTAssert(app.staticTexts["device.rdc.accounts.error"].waitForExistence(), "Expected a failed to load message.")
        XCTAssert(app.buttons["Try Again"].waitForExistence(), "Expected to find try again button.")
    }

    func testTryAgainReloadsAccountsWhenTouched() {
        proceedToDepositFlow()

        // It is important to use the accessibility identifier here as the deposit
        // view is presented modally and not full screen so any try again button on the
        // previous page will still be in the view hierarchy and the XCUIElementQuery will
        // yield multiple results for the try again button.
        let tryAgainButton = app.buttons["try-again-deposit-view-controller"]
        XCTAssert(tryAgainButton.waitForExistence(), "Expected to find try again button.")

        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        tryAgainButton.tap()

        XCTAssert(fullyLoadedDepositPageAppears())
    }

    func testDepositButtonStartsAsDisabled() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let submitButton = app.buttons["dashboard.widget.deposit.btn.submit"]
        XCTAssert(submitButton.waitForExistence(), "Expected to find submit button.")
        XCTAssert(!submitButton.isEnabled, "Expected submit button to be disabled.")
    }

    func testThatDepositButtonBecomsEnabledWhenAddingImagesAmountAndAccount() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()
        fillOutDepositForm()

        XCTAssert(
            app.buttons["dashboard.widget.deposit.btn.submit"].isEnabled,
            "Expected the submit button to be enabled when form is filled out."
        )
    }

    // MARK: Confirmation View Controller

    func testConfirmationAppears() {
        proceedToConfirmationPage()
        waitForDepositConfirmationToAppear()
    }

    func testConfirmationSubmitShowsNetworkErrorAlert() {
        // We have not setup a success response for the confirm submission so
        // we should get an error when we submit here.
        proceedToConfirmationPage()

        app.buttons["dashboard.widget.deposit.btn.confirm"].tap()

        // Make sure the alert appears as expected.
        waitForConfirmationNetworkErrorAlertToAppear()

        // Dismiss the alert and ensure that it goes away
        app.alerts.firstMatch.buttons["app.alert.btn.ok"].tap()

        waitForConfirmationNetworkErrorAlertToDismiss()
    }

    func testConfirmationSubmitGoesToSuccessPage() {
        proceedToDepositSuccessPage()
        waitForDepositSuccessPageToAppear()
    }

    // MARK: Success Page

    func testTouchingAllDoneOnSuccessPageReturnsUserToHistoryPage() {
        proceedToDepositSuccessPage()
        waitForDepositSuccessPageToAppear()

        app.buttons["dashboard.widget.deposit.btn.all-done"].tap()

        waitForHistoryPageToAppear()
        waitForHistoryPageToBeHittable()
    }

    func testTouchingCloseOnConfirmationGivesAreYouSureAlert() {
        // This will go all the way to the alert and make it
        // appear. The test will fail if the wait inside of
        // this method fails.
        proceedToConfirmationAreYouSureAlert()
    }

    // MARK: Error Page

    func testErrorPageIsShownForDepositFailure() {
        proceedToDepositErrorPage()
        waitForDepositErrorPageToAppear()
    }

    func testTouchingCancelOnErrorPageReturnsToHistoryPage() {
        proceedToDepositErrorPage()
        waitForDepositErrorPageToAppear()

        app.buttons["rdc-deposit-error-cancel-button"].tap()

        waitForHistoryPageToAppear()
        waitForHistoryPageToBeHittable()
    }

    func testTouchingTryAgainOnErrorPageGoesToDepositPage() {
        proceedToDepositErrorPage()
        waitForDepositErrorPageToAppear()

        mockServerRule.post(depositSubmitPath, jsonPath: "RDCResponses/rdc-deposit-success.json")
        app.buttons["rdc-deposit-error-try-again-button"].tap()

        XCTAssert(fullyLoadedDepositPageAppears())
    }

    func testTouchingCancelOnAreYouSureAlertTakesYouBackToConfirmation() {
        proceedToConfirmationAreYouSureAlert()

        app.alerts.firstMatch.buttons["app.alert.btn.cancel"].tap()

        waitForAreYouSureAlertToNotExist()
        waitForDepositConfirmationToAppear()
        waitForDepositConfirmationToBeHittable()
    }

    func testTouchingOkOnAreYouSureAlertTakesYouBackToHistoryPage() {
        proceedToConfirmationAreYouSureAlert()

        app.alerts.firstMatch.buttons["app.alert.btn.ok"].tap()

        waitForDepositConfirmationToDismiss()
        waitForHistoryPageToAppear()
        waitForHistoryPageToBeHittable()
    }

    // MARK: Check Images

    func testThatCheckImagesAreNotPresentUntilCaptured() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let checkImageCell = app.tables.firstMatch.cells.allElementsBoundByIndex[0]

        XCTAssert(!checkImageCell.images["rdc.frontCheckImage.accessibilityLabel"].exists)
        XCTAssert(!checkImageCell.images["rdc.backCheckImage.accessibilityLabel"].exists)

        let takeImageButton = checkImageCell.buttons["dashboard.widget.deposit.btn.capture"]
        XCTAssert(takeImageButton.waitForExistence())
        takeImageButton.tap()

        XCTAssert(checkImageCell.images["rdc.frontCheckImage.accessibilityLabel"].waitForExistence())
        XCTAssert(checkImageCell.images["rdc.backCheckImage.accessibilityLabel"].waitForExistence())
    }

    // MARK: Deposit Amount Field

    func testTypingInAmountFieldProducesExpectedResult() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()

        let amountTextField = app.tables.firstMatch.textFields["deposit-amount-textField"]
        XCTAssert(amountTextField.waitForExistence())

        amountTextField.tap()

        app.buttons["1"].tap()
        XCTAssert((amountTextField.value as! String) == "$0.01")

        app.buttons["2"].tap()
        XCTAssert((amountTextField.value as! String) == "$0.12")

        app.buttons["3"].tap()
        XCTAssert((amountTextField.value as! String) == "$1.23")

        app.buttons["4"].tap()
        XCTAssert((amountTextField.value as! String) == "$12.34")

        app.buttons["5"].tap()
        XCTAssert((amountTextField.value as! String) == "$123.45")

        app.buttons["6"].tap()
        XCTAssert((amountTextField.value as! String) == "$1,234.56")

        app.buttons["7"].tap()
        XCTAssert((amountTextField.value as! String) == "$12,345.67")

        app.buttons["8"].tap()
        XCTAssert((amountTextField.value as! String) == "$123,456.78")

        app.buttons["9"].tap()
        XCTAssert((amountTextField.value as! String) == "$1,234,567.89")

        app.buttons["0"].tap()
        XCTAssert((amountTextField.value as! String) == "$12,345,678.90")

        for i in 1...10 {
            app.buttons["⌫"].tap()

            // Check at some arbitrary character to make sure the formatting
            // still holds with the deleted keys
            if i == 5 {
                XCTAssert((amountTextField.value as! String) == "$123.45")
            }
        }

        // Now that we have deleted all of the digits the value should be back to $0.00
        XCTAssert((amountTextField.value as! String) == "$0.00")

        // Make sure that extra deletes leave the value at zero.
        app.buttons["⌫"].tap()
        XCTAssert((amountTextField.value as! String) == "$0.00")
    }

    // MARK: Helpers
    
    private func proceedToDashboard(rdcAllowed: Bool = true) {
        mockServerRule.prefix(path: "/auth/challenge", jsonPath: "authentication") { router in
            router.get("", jsonPath: "/initial-challenge.json")
            router.post("", jsonPath: "/authenticated-challenge.json")
        }
        mockServerRule.get(
            "/auth/session",
            jsonPath: rdcAllowed
                ? "RDCSessions/rdc-session-standard.json"
                : "RDCSessions/rdc-session-no-rdc.json"
        )

        app.launch()

        app.textFields["Enter user name"].focusAndType("samualadamsiii")
        app.secureTextFields["Enter password"].focusAndType("password")
        app.buttons["Submit"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence())
    }

    private func openRDC() {
        let tabBar = app.tabBars.firstMatch
        XCTAssert(tabBar.waitForExistence(), "Did not find tab bar.")

        // If the RDC tab bar item is in the main tab bar items go ahead and tap it.
        // Other wise check the more menu to find it and tap it.
        if tabBar.buttons["RDC"].waitForExistence() {
            tabBar.buttons["RDC"].tap()
        } else {
            XCTAssert(tabBar.buttons["More"].waitForExistence())
            tabBar.buttons["More"].tap()

            XCTAssert(app.staticTexts["RDC"].waitForExistence())
            app.staticTexts["RDC"].tap()
        }
    }

    private func proceedToDepositFlow(historyEnabled: Bool = true) {
        mockServerRule.get(
            "/v3/startup/ui",
            jsonPath: historyEnabled
                ? "RDCStartup/rdc-startup-ui-history-enabled.json"
                : "RDCStartup/rdc-startup-ui-history-disabled.json"
        )

        proceedToDashboard()
        openRDC()

        app.staticTexts["dashboard.widget.deposit.btn.launch"].tap()
    }

    private func proceedToConfirmationPage() {
        mockServerRule.get(depositAccountsPath, jsonPath: "RDCResponses/rdc-deposit-accounts.json")

        proceedToDepositFlow()
        fillOutDepositForm()

        // If we were able to fill out the deposit form then we know that
        // the submit button is present.
        app.buttons["dashboard.widget.deposit.btn.submit"].tap()
    }

    private func proceedToConfirmationAreYouSureAlert() {
        proceedToConfirmationPage()
        waitForDepositConfirmationToAppear()

        app.buttons["rdc-confirmation-close-button"].tap()

        waitForAreYouSureAlertToAppear()
    }

    private func proceedToDepositSuccessPage() {
        mockServerRule.post(depositSubmitPath, jsonPath: "RDCResponses/rdc-deposit-success.json")
        confirmDeposit()
    }

    private func proceedToDepositErrorPage() {
        mockServerRule.post(depositSubmitPath, jsonPath: "RDCResponses/rdc-deposit-failure.json")
        confirmDeposit()
    }

    private func confirmDeposit() {
        proceedToConfirmationPage()
        app.buttons["dashboard.widget.deposit.btn.confirm"].tap()
    }

    private func fillOutDepositForm() {
        let table = app.tables.firstMatch

        let submitButton = app.buttons["dashboard.widget.deposit.btn.submit"]
        XCTAssert(submitButton.waitForExistence(), "Expected to find submit button.")
        XCTAssert(!submitButton.isEnabled, "Expected submit button to be disabled.")

        let amountTextField = app.textFields["deposit-amount-textField"]
        amountTextField.focusAndType("1")
        app.buttons["Done"].tap()
        XCTAssert(!submitButton.isEnabled, "Expected submit button to be disabled.")

        let firstAccount = table
            .cells
            .allElementsBoundByIndex[1]
            .otherElements["checkbox-Consumer Checking Account"]
        XCTAssert(firstAccount.waitForExistence())
        firstAccount.tap()
        XCTAssert(!submitButton.isEnabled, "Expected submit button to be disabled.")

        let takeImageButton = table.buttons["dashboard.widget.deposit.btn.capture"]
        XCTAssert(takeImageButton.waitForExistence())
        takeImageButton.tap()
    }

    private func depositLandingPageAppears() -> Bool {
        // Check to make sure that there is no history table view.
        // and to see that the rdc flow launch button is present.
        return !app.tables.firstMatch.exists
            && app.staticTexts["dashboard.widget.deposit.btn.launch"].waitForExistence()
    }

    private func waitForLandingPageToBeHittable() {
        expectation(for: doesNotExistPredicate, evaluatedWith: app.tables.firstMatch)
        expectation(for: isHittablePredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.btn.launch"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForAreYouSureAlertToAppear() {
        waitForAreYouSureAlert(toMatch: existsPredicate)
    }

    private func waitForAreYouSureAlertToNotExist() {
        let doesNotExistPredicate = NSPredicate(format: "exists == %d", 0)
        waitForAreYouSureAlert(toMatch: doesNotExistPredicate)
    }

    private func waitForAreYouSureAlert(toMatch predicate: NSPredicate) {
        let alert = app.alerts.firstMatch

        expectation(for: predicate, evaluatedWith: alert)
        expectation(for: predicate, evaluatedWith: alert.staticTexts["dashboard.widget.deposit.flow-cancel.title"])
        expectation(for: predicate, evaluatedWith: alert.staticTexts["dashboard.widget.deposit.flow-cancel.text"])
        expectation(for: predicate, evaluatedWith: alert.buttons["app.alert.btn.ok"])
        expectation(for: predicate, evaluatedWith: alert.buttons["app.alert.btn.cancel"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func fullyLoadedDepositPageAppears() -> Bool {
        let table = app.tables.firstMatch

        // There should be one cell for the capture button, check images, and amount field and
        // two history items.
        guard table.waitForExistence() else { return false }
        guard table.cells.count == 3 else { return false }

        let item1 = table.cells.allElementsBoundByIndex[1]
        let item2 = table.cells.allElementsBoundByIndex[2]

        return app.staticTexts["dashboard.widget.deposit-now"].exists
            && app.buttons["dashboard.widget.deposit.btn.capture"].waitForExistence()
            && app.textFields["deposit-amount-textField"].waitForExistence()
            && app.staticTexts["deposit.account.placeholder"].waitForExistence()
            && item1.otherElements
                .matching(identifier: "checkbox-Consumer Checking Account")
                .firstMatch.waitForExistence()
            && item1.staticTexts["$20.00"].waitForExistence()
            && item2.otherElements
                .matching(identifier: "checkbox-My Deposit - Savings Account")
                .firstMatch.waitForExistence()
            && item2.staticTexts["$10,099.00"].waitForExistence()
    }

    private func waitForHistoryPageToAppear() {
        waitForHistoryPage(toMatch: existsPredicate)
    }

    private func waitForHistoryPageToBeHittable() {
        waitForHistoryPage(toMatch: isHittablePredicate)
    }

    private func waitForHistoryPage(toMatch predicate: NSPredicate) {
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.history.title"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.btn.launch"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.history.deposit-delay"])
        expectation(for: predicate, evaluatedWith: app.tables.firstMatch)

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    /// Waits for the elements of the deposit page (the page itself) to no longer exist.
    /// this is usefull for waiting on animations to complete to ensure that the views
    /// are removed from the view hierarchy.
    private func waitForDepositPageToNotExist() {
        expectation(for: doesNotExistPredicate, evaluatedWith: app.staticTexts["dasboard.widget.deposit-now"])
        expectation(for: doesNotExistPredicate, evaluatedWith: app.buttons["dashboard.widget.deposit.btn.capture"])
        expectation(for: doesNotExistPredicate, evaluatedWith: app.textFields["deposit-amount-textField"])
        expectation(for: doesNotExistPredicate, evaluatedWith: app.staticTexts["deposit.account.placeholder"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForDepositDetailsPageToExist() {
        expectation(for: existsPredicate, evaluatedWith: app.buttons["dashboard.widget.deposit.history.title"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.front"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.back"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.status:"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.transactiondate:"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.submittedamount:"])
        expectation(for: existsPredicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.detail.currentamount:"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForDepositConfirmationToAppear() {
        waitForDepositConfirmation(toMatch: existsPredicate)
    }

    private func waitForDepositConfirmationToBeHittable() {
        waitForDepositConfirmation(toMatch: isHittablePredicate)
    }

    private func waitForDepositConfirmationToDismiss() {
        let doesNotExistPredicate = NSPredicate(format: "exists == %d", 0)
        waitForDepositConfirmation(toMatch: doesNotExistPredicate)
    }

    private func waitForDepositConfirmation(toMatch predicate: NSPredicate) {
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit-now"])
        expectation(for: predicate, evaluatedWith: app.buttons["rdc-confirmation-close-button"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["rdc.confirmation.subtitle"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["$0.01"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.confirm.string"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["disclosure-title"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["disclosure-text"])
        expectation(for: predicate, evaluatedWith: app.buttons["dashboard.widget.deposit.btn.confirm"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForConfirmationNetworkErrorAlertToAppear() {
        waitForConfirmationNetworkErrorAlert(toMatch: existsPredicate)
    }

    private func waitForConfirmationNetworkErrorAlertToDismiss() {
        waitForConfirmationNetworkErrorAlert(toMatch: doesNotExistPredicate)
    }

    private func waitForConfirmationNetworkErrorAlert(toMatch predicate: NSPredicate) {
        let alert = app.alerts.firstMatch
        expectation(for: predicate, evaluatedWith: alert)
        expectation(for: predicate, evaluatedWith: alert.staticTexts["dashboard.widget.deposit.error.title"])
        expectation(for: predicate, evaluatedWith: alert.staticTexts["dashboard.widget.deposit.unsuccessful.title"])
        expectation(for: predicate, evaluatedWith: alert.buttons["app.alert.btn.ok"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForDepositSuccessPageToAppear() {
        XCTAssert(app.staticTexts["dashboard.widget.deposit-now"].waitForExistence(), "Page title never appeared.")
        XCTAssert(app.staticTexts["dashboard.widget.deposit.success.title"].waitForExistence(), "Deposit success title never appeared.")
        XCTAssert(app.staticTexts["dashboard.widget.deposit.success.text"].waitForExistence(), "Deposit success text never appeared.")
        XCTAssert(app.buttons["dashboard.widget.deposit.btn.all-done"].waitForExistence(), "All done button never appeared.")
    }

    private func waitForDepositSuccessPage(toMatch predicate: NSPredicate) {
        let expectations = [
            expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit-now"]),
            expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.success.title"]),
            expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.success.text"]),
            expectation(for: predicate, evaluatedWith: app.buttons["dashboard.widget.deposit.btn.all-done"])
        ]
        
        wait(for: expectations, timeout: XCTestExpectation.standardTimeout)
    }

    private func waitForDepositErrorPageToAppear() {
        waitForDepositErrorPage(toMatch: existsPredicate)
    }

    private func waitForDepositErrorPage(toMatch predicate: NSPredicate) {
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.failed"])
        expectation(for: predicate, evaluatedWith: app.staticTexts["dashboard.widget.deposit.unsuccessful.title"])
        expectation(for: predicate, evaluatedWith: app.buttons["rdc-deposit-error-cancel-button"])
        expectation(for: predicate, evaluatedWith: app.buttons["rdc-deposit-error-try-again-button"])

        waitForExpectations(timeout: XCTestExpectation.standardTimeout)
    }
}
