//
//  PTRecipientViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/30/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import PayTransfer

final class PTRecipientViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testPTRecipientViewControllerView() {
        let controller = StoryboardScene.payTransfer.recipientViewController.instantiate()
        controller.serviceItem = PayTransferServiceMock()
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
