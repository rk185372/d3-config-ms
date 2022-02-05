//
//  AuthViewControllerTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import FBSnapshotTestCase
import Foundation

@testable import D3_N3xt

final class AuthViewControllerTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()

        isDeviceAgnostic = true
        recordMode = false
    }

    func testAuthViewControllerView() {
        let exp = expectation(description: "exp")
        
        let authController = StoryboardScene.AuthFlow.initialScene.instantiate()
        authController.locationsService = LocationsServiceMock()
        let view = authController.view!
        authController.hideLocationsLoadingIndicator(animated: false)
        view.setNeedsDisplay()
        view.layoutIfNeeded()

        // Note the time out here to make sure that the snapshot is showing
        _ = XCTWaiter.wait(for: [exp], timeout: 0.75)
        FBSnapshotVerifyView(view)
    }
}
