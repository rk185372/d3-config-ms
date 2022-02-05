//
//  AccountsViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import Accounts
@testable import AccountsPresentation
@testable import TransactionsPresentation

final class AccountsViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testAccountsViewControllerView() {
        let transactionsViewControllerFactory = TransactionsViewControllerFactory(transactionsService: TransactionsServiceMock())
        let controller = AccountsViewController(accountsService: AccountsServiceMock(), transactionsViewControllerFactory: transactionsViewControllerFactory)
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
