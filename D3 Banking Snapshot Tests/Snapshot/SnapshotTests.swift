//
//  SnapshotTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import D3_N3xt

final class SnapshotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testSnapshotViewControllerView() {
        let controller = StoryboardScene.Snapshot.initialScene.instantiate()
        controller.snapshotService = SnapshotServiceMock()
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
