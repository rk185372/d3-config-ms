//
//  NavigationItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/2/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation

public enum NavigationItem {
    case account
    case locations
    case logout
    case messages
    case moneyMovement
    case mrdc
    case planning
    case selfService
    case settings
    case approvals

    var icon: UIImage? {
        switch self {
        case .account:
            return UIImage(named: "AccountsTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .locations:
            return UIImage(named: "LocationsTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .logout:
            return UIImage(named: "LogoutTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .moneyMovement:
            return UIImage(named: "PayTransferTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .mrdc:
            return UIImage(named: "RdcTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .messages:
            return UIImage(named: "MessagesTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .planning:
            return UIImage(named: "PlanningTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .selfService:
            return UIImage(named: "SelfServiceTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        case .approvals:
            return UIImage(named: "Approvals", in: DashboardBundle.bundle, compatibleWith: nil)
        case .settings:
            return UIImage(named: "SettingsTabIcon", in: DashboardBundle.bundle, compatibleWith: nil)
        }
    }
    
    var titleL10nKey: String {
        switch self {
        case .account:
            return "nav.accounts"
        case .locations:
            return "launchPage.geolocation.title"
        case .logout:
            return "header.logout"
        case .messages:
            return "nav.messages"
        case .moneyMovement:
            return "nav.money.movement"
        case .mrdc:
            return "dashboard.widget.deposit.btn"
        case .planning:
            return "nav.planning"
        case .selfService:
            return "nav.self-service"
        case .approvals:
            return "nav.approvals"
        case .settings:
            return "nav.settings"
        }
    }
}
