//
//  PTConfirmationViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/30/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import PayTransfer

final class PTConfirmationViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testPTConfirmationViewControllerView() {
        let controller = StoryboardScene.payTransfer.confirmationViewController.instantiate()
        controller.recipient = Recipient(id: 0, name: "My Fav Recipient", transferAccount: true, abbreviatedName: "MF")
        controller.amount = Amount(amount: 100.00, display: "$100.00")
        controller.date = PTDate(string: "06/12/2016")
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
