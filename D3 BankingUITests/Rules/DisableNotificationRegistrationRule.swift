//
//  DisableNotificationRegistrationRule.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 1/27/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

final class DisableNotificationRegistrationRule: TestRule {

    init() {}

    func setup(_ app: XCUIApplication) {
        app.launchArguments += ["-disableNotificationRegistration"]
    }

    func rulesHaveBeenSetup(otherRules: [TestRule]) {}

    func tearDown(_ app: XCUIApplication) {}
}
