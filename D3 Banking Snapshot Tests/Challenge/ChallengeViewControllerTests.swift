//
//  ChallengeViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import D3_N3xt

final class ChallengeViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testChallengeViewControllerView() {
        let controller = StoryboardScene.Challenge.initialScene.instantiate()
        controller.challengeService = ChallengeServiceMock()
        let view = controller.view!

        FBSnapshotVerifyView(view)
    }
}
