//
//  DashboardViewControllerFactory.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/2/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import UIKit
import RootViewController
import ComponentKit
import Session
import Localization
import Messages
import Offline
import Utilities
import SessionExpiration
import InAppRatingApi

public final class DashboardViewControllerFactory {
    private let config: ComponentConfig
    private let monitor: ReachabilityMonitor?
    private let statsManager: MessageStatsManager
    private let styleProvider: ComponentStyleProvider
    private let sessionExpirationWarningManagerFactory: SessionExpirationWarningManagerFactory
    private let inAppRatingManager: InAppRatingManager
    private let landingFlowFactory: DashboardLandingFlowFactory

    public init(config: ComponentConfig,
                monitor: ReachabilityMonitor?,
                messageStatsManager: MessageStatsManager,
                componentStyleProvider: ComponentStyleProvider,
                sessionExpirationWarningManagerFactory: SessionExpirationWarningManagerFactory,
                inAppRatingManager: InAppRatingManager,
                landingFlowFactory: DashboardLandingFlowFactory) {
        self.config = config
        self.monitor = monitor
        self.statsManager = messageStatsManager
        self.styleProvider = componentStyleProvider
        self.sessionExpirationWarningManagerFactory = sessionExpirationWarningManagerFactory
        self.inAppRatingManager = inAppRatingManager
        self.landingFlowFactory = landingFlowFactory
    }
    
    func create(withTabBarViewControllers controllers: [UIViewController]) -> UIViewController {
        let tabBarController = DashboardViewController(
            config: config,
            sessionExpirationWarningManager: sessionExpirationWarningManagerFactory.create(),
            monitor: monitor,
            inAppRatingManager: inAppRatingManager,
            messageStatsManager: statsManager,
            landingFlow: landingFlowFactory.create()
        )
        tabBarController.viewControllers = controllers
        tabBarController.selectedIndex = 0
        
        return tabBarController
    }
}
