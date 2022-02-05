//
//  ProvidesMockRDCImages.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 2/18/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class ProvidesMockRDCImages: TestRule {

    init() {}

    func setup(_ app: XCUIApplication) {
        app.launchEnvironment["rdcTestImage"] = FileHelper.stringContents(of: "test-check-image", withType: "jpg", in: "RDCTestImages")
    }

    func rulesHaveBeenSetup(otherRules: [TestRule]) {}

    func tearDown(_ app: XCUIApplication) {}
}
