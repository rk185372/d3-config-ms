//
//  PermissionsManagerTests.swift
//  D3 BankingTests
//
//  Created by Jose Torres on 10/6/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import XCTest
@testable import Session
@testable import Permissions

final class PermissionsManagerTests: XCTestCase {
    
    private var permissionsManager: PermissionsManager!
    private var userSession: UserSession!
    
    override func setUp() {
        userSession = UserSession()
        userSession.rawSession = rawSession()
        permissionsManager = PermissionsManager(rules: [:])
        permissionsManager.roles = userSession.roles
    }
        
    func testPermissionManagerWithExistingPermissionReadAccess() {
        XCTAssertTrue(permissionsManager.hasRole(role: "settings.dashboard"))
        XCTAssertFalse(permissionsManager.hasRole(role: "settings.dashboard", access: .delete))
        XCTAssertFalse(permissionsManager.hasRole(role: "settings.dashboard", access: .create))
        XCTAssertFalse(permissionsManager.hasRole(role: "settings.dashboard", access: .update))
    }
    
    func testPermissionManagerWithExistingPermissionReadUpdateAccess() {
        XCTAssertTrue(permissionsManager.hasRole(role: "dashboard.plan"))
        XCTAssertFalse(permissionsManager.hasRole(role: "dashboard.plan", access: .delete))
        XCTAssertFalse(permissionsManager.hasRole(role: "dashboard.plan", access: .create))
        XCTAssertTrue(permissionsManager.hasRole(role: "dashboard.plan", access: .update))
    }
    
    func testPermissionManagerWithExistingPermissionReadDeleteCreateAccess() {
        XCTAssertTrue(permissionsManager.hasRole(role: "money-movement"))
        XCTAssertTrue(permissionsManager.hasRole(role: "money-movement", access: .delete))
        XCTAssertTrue(permissionsManager.hasRole(role: "money-movement", access: .create))
        XCTAssertFalse(permissionsManager.hasRole(role: "money-movement", access: .update))
    }
    
    func testPermissionManagerWithExistingPermissionReadDeleteCreateUpdateAccess() {
        XCTAssertTrue(permissionsManager.hasRole(role: "settings.alerts"))
        XCTAssertTrue(permissionsManager.hasRole(role: "settings.alerts", access: .delete))
        XCTAssertTrue(permissionsManager.hasRole(role: "settings.alerts", access: .create))
        XCTAssertTrue(permissionsManager.hasRole(role: "settings.alerts", access: .update))
    }
        
    func testPermissionManagerWithExistingPermissionEmptyAccess() {
        XCTAssertFalse(permissionsManager.hasRole(role: "money-movement.schedule"))
        XCTAssertFalse(permissionsManager.hasRole(role: "money-movement.schedule", access: .delete))
        XCTAssertFalse(permissionsManager.hasRole(role: "money-movement.schedule", access: .create))
        XCTAssertFalse(permissionsManager.hasRole(role: "money-movement.schedule", access: .update))
    }
    
    func testPermissionManagerWithNonExistingPermissionAccess() {
        XCTAssertFalse(permissionsManager.hasRole(role: "nonexisting.permission"))
    }
    
    func testPermissionManagerMoneyMapAndPulseAccessibles() {
        permissionsManager.financialWellnessPermissions = MockedFWPermissions(isMoneyMapEnabled: true, isPulseEnabled: true)
        XCTAssertTrue(permissionsManager.isAccessible(feature: .moneyMap))
        XCTAssertTrue(permissionsManager.isAccessible(feature: .pulse))
    }
    
    func testPermissionManagerMoneyMapNotAccessible() {
        permissionsManager.financialWellnessPermissions = MockedFWPermissions(isMoneyMapEnabled: false, isPulseEnabled: true)
        XCTAssertFalse(permissionsManager.isAccessible(feature: .moneyMap))
        XCTAssertTrue(permissionsManager.isAccessible(feature: .pulse))
    }
    
    func testPermissionManagerPulseNotAccessible() {
        permissionsManager.financialWellnessPermissions = MockedFWPermissions(isMoneyMapEnabled: true, isPulseEnabled: false)
        XCTAssertTrue(permissionsManager.isAccessible(feature: .moneyMap))
        XCTAssertFalse(permissionsManager.isAccessible(feature: .pulse))
    }
    
    private func rawSession() -> RawSession {
        let data = try! Data(
            contentsOf: URL(
                fileURLWithPath: "SampleUserSessionPermissions.json",
                relativeTo: Bundle(for: type(of: self)).bundleURL
            ),
            options: .alwaysMapped
        )

        return try! JSONDecoder().decode(RawSession.self, from: data)
    }
}

private struct MockedFWPermissions: FinancialWellnessPermisions {
    let isMoneyMapEnabled: Bool
    let isPulseEnabled: Bool
    
    func isAccessible(_ feature: Feature) -> Bool {
        switch feature {
        case .moneyMap:
            return isMoneyMapEnabled
        case .pulse:
            return isPulseEnabled
        default:
            return true
        }
    }
}
