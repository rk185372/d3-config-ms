//
//  SnapshotTests.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/22/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class SnapshotTests: RuleBasedTest {
    let mockServerRule: MockServerRule = MockServerRule()
    let providesL10nRule: ProvidesL10nRule = ProvidesL10nRule(l10nFilePath: "snapshot/snapshot-l10n.json")
    let providesThemeRule: ProvidesThemeRule = ProvidesThemeRule(themeFilePath: "CommonData/theme.json")
    let providesWebThemeRule: ProvidesWebThemeRule = ProvidesWebThemeRule(themeFilePath: "WebViewContents/webtheme.json")
    let disablesNotificationRegistrationRule: DisableNotificationRegistrationRule = DisableNotificationRegistrationRule()
    let overrideDefaultsRule: OverrideDefaultsRule = OverrideDefaultsRule(defaults: [
        .init(key: "performedSnapshotSetup", value: "0"),
        .init(key: "performedBiometricsSetup", value: "1"),
        .init(key: "snapshotToken", value: "adfa")
    ])
    
    override func setUp() {
        super.setUp()
        
        mockServerRule.prefix(jsonPath: "CommonData/standard-startup") { router in
            router.prefix(path: "/startup", jsonPath: "/startup", router: { router in
                router.get("/ui", jsonPath: "/ui.json")
                router.get("/mobile-initialization", jsonPath: "/mobile-initialization.json")
            })
            router.get("/view/quick$", jsonPath: "/view/quick.json")
            router.get("/auth/challenge", jsonPath: "/auth/challenge.json")
        }
    }
    
    func testSnapshotLoadingIndicatorIsDisplayed() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts.json", delay: .delay(seconds: 12))
        
        app.launch()
        
        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()
        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertTrue(app.tables.cells.count == 1)
    }

    func testSnapshotDetailLoadingIndicatorIsDisplayed() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts.json", delay: .delay(seconds: 12))
        mockServerRule.post("/view/quick/*/", jsonPath: "snapshot/transactions.json", delay: .delay(seconds: 12))

        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.firstMatch
        firstCell.tap()
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertTrue(app.tables.cells.count == 1)
    }
    
    func testReloadIsDisplayedOnFailure() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts.json", status: .failure)
        
        app.launch()
        
        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()
        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        // swiftlint:disable:next empty_count
        XCTAssertTrue(app.tables.cells.count == 0)
    }

    func testSnapshotCellsAppear() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts.json")

        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(3, tablesQuery.cells.count)
    }

    func testMultipleAccounts() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts.json")
        mockServerRule.post("/view/quick/*/", jsonPath: "snapshot/transactions.json")

        app.activate()
        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(3, tablesQuery.cells.count)

        let firstCell = tablesQuery.cells.firstMatch
        firstCell.tap()

        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(9, tablesQuery.cells.count)

        XCTAssertTrue(app.staticTexts["My Deposit - Checking Account"].waitForExistence())
        XCTAssertTrue(app.staticTexts["******7445"].waitForExistence())
        XCTAssertTrue(app.staticTexts["$1,200.00"].waitForExistence())
        XCTAssertTrue(app.tables.staticTexts["10 Most recent transactions of the last 30 days"].waitForExistence())
    }

    func testMultipleAccountsNoTransactions() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_multiple_accounts_transactions_disabled.json")

        app.activate()
        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(3, tablesQuery.cells.count)

        let firstCell = tablesQuery.cells.firstMatch
        firstCell.tap()

        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(0, tablesQuery.cells.count)

        XCTAssertTrue(app.staticTexts["My Deposit - Checking Account"].waitForExistence())
        XCTAssertTrue(app.staticTexts["******7445"].waitForExistence())
        XCTAssertTrue(app.staticTexts["$1,200.00"].waitForExistence())
    }

    func testSingleAccount() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_single_account.json")

        app.activate()
        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(3, tablesQuery.cells.count)

        XCTAssertTrue(app.staticTexts["My Deposit - Checking Account"].waitForExistence())
        XCTAssertTrue(app.staticTexts["******7445"].waitForExistence())
        XCTAssertTrue(app.staticTexts["$1,200.00"].waitForExistence())
        XCTAssertTrue(app.tables.staticTexts["10 Most recent transactions of the last 30 days"].waitForExistence())
    }

    func testSingleAccountNoBalances() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_single_account_no_balances.json")

        app.activate()
        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(3, tablesQuery.cells.count)

        XCTAssertTrue(app.staticTexts["My Deposit - Checking Account"].waitForExistence())
        XCTAssertTrue(app.staticTexts["******7445"].waitForExistence())

        let tooltipText = "Your account balance is not enabled at this time. " +
        "Please log in and update account settings for those accounts you would like displayed."

        let predicate = NSPredicate(format: "label LIKE %@", tooltipText)
        XCTAssertTrue(app.staticTexts.element(matching: predicate).waitForExistence())
        XCTAssertTrue(app.tables.staticTexts["10 Most recent transactions of the last 30 days"].waitForExistence())
    }

    func testSingleAccountTransactionsDisabled() {
        mockServerRule.post("/view/quick$", jsonPath: "snapshot/snapshot_single_account_no_transactions.json")

        app.activate()
        app.launch()

        let snapshotButton = app.buttons["Snapshot"]
        XCTAssertTrue(snapshotButton.waitForExistence())
        snapshotButton.tap()

        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence())
        XCTAssertEqual(0, tablesQuery.cells.count)

        XCTAssertTrue(app.staticTexts["My Deposit - Checking Account"].waitForExistence())
        XCTAssertTrue(app.staticTexts["******7445"].waitForExistence())

        let tooltipText = "launchPage.snapshot.no-recent-transactions"

        let predicate = NSPredicate(format: "label LIKE %@", tooltipText)
        XCTAssertTrue(app.staticTexts.element(matching: predicate).waitForExistence())
        XCTAssertTrue(app.staticTexts["$1,200.00"].waitForExistence())
    }
}
