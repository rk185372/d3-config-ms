//
//  NavigationProvider.swift
//  D3 Banking
//
//  Created by Branden Smith on 11/11/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import ComponentKit
import Dip
import Foundation
import Localization
import Messages
import Permissions
import UIKit
import Utilities

final class NavigationProvider {

    private let l10nProvider: L10nProvider
    private let styleProvider: ComponentStyleProvider
    private let messageStatsManager: MessageStatsManager
    private let permissionsManager: PermissionsManager

    init(l10nProvider: L10nProvider,
         styleProvider: ComponentStyleProvider,
         statsManager: MessageStatsManager,
         permissionsManager: PermissionsManager) {
        self.l10nProvider = l10nProvider
        self.styleProvider = styleProvider
        self.messageStatsManager = statsManager
        self.permissionsManager = permissionsManager
    }

    func provideNavigationViewControllers(givenDependencyContainer container: DependencyContainer) -> [UIViewController] {
        return NavigationItem.allCases.compactMap { navItem in
            guard let factory = navItem.viewControllerFactory(givenDependencyContainer: container) as? ViewControllerFactory & Permissioned,
                permissionsManager.isAccessible(feature: factory.feature) else { return nil }

            let viewController = factory.create()

            let title = l10nProvider.localize(navItem.titleL10nKey)

            if let navigationController = viewController as? UINavigationController {
                navigationController.viewControllers.first?.navigationItem.title = title
            }
            viewController.tabBarItem.title = title
            viewController.tabBarItem.image = navItem.icon!

            if let vc = viewController as? BadgeManager {
                switch navItem {
                case .messages:
                    vc.set(
                        badgeManager: TabBarBadgeManager(
                            badgeCount: messageStatsManager.secureMessageCount,
                            styleProvider: styleProvider
                        )
                    )
                    
                case .alerts:
                    vc.set(
                        badgeManager: TabBarBadgeManager(
                            badgeCount: messageStatsManager.alertsCount,
                            styleProvider: styleProvider
                        )
                    )
                case .approvals:
                    vc.set(
                        badgeManager: TabBarBadgeManager(
                            badgeCount: messageStatsManager.approvalsCount,
                            styleProvider: styleProvider
                        )
                    )
                    
                default:
                    break
                }
            }
            
            if let vc = viewController as? BadgeMoreViewManager {
                switch navItem {
                case .messages:
                    vc.set(
                        badgeMoreViewManager: TabBarBadgeMoreViewManager(
                            badgeCount: messageStatsManager.secureMessageCount,
                            styleProvider: styleProvider
                        ),
                        type: .messages
                    )
                    
                case .alerts:
                    vc.set(
                        badgeMoreViewManager: TabBarBadgeMoreViewManager(
                            badgeCount: messageStatsManager.alertsCount,
                            styleProvider: styleProvider
                        ),
                        type: .alerts
                    )
                    
                case .approvals:
                    vc.set(
                        badgeMoreViewManager: TabBarBadgeMoreViewManager(
                            badgeCount: messageStatsManager.approvalsCount,
                            styleProvider: styleProvider
                        ),
                        type: .approvals
                    )
                    
                default:
                    break
                }
            }
            
            return viewController
        }
    }
}
