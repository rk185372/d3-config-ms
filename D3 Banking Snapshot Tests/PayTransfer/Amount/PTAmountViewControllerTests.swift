//
//  PTAmountViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/30/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import PayTransfer

final class PTAmountViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testPTAmountViewControllerView() {
        let controller = StoryboardScene.payTransfer.amountViewController.instantiate()
        controller.serviceItem = PayTransferServiceMock()
        controller.recipient = Recipient(id: 0, name: "My Fav Recipient", transferAccount: true, abbreviatedName: "Bestie")
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
