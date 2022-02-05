//
//  AppInitializationViewControllerFactory.swift
//  AppInitialization
//
//  Created by Andrew Watt on 7/10/18.
//

import UIKit
import Localization
import Navigation
import CompanyAttributes
import Utilities
import ComponentKit
import GBVersionTracking
import Offline

public final class AppInitializationViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let upgradeViewControllerFactory: UpgradeViewControllerFactory
    private let offlineViewControllerFactory: OfflineViewControllerFactory
    private let tasks: [InitializationTask]

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                upgradeViewControllerFactory: UpgradeViewControllerFactory,
                offlineViewControllerFactory: OfflineViewControllerFactory,
                tasks: [InitializationTask]) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.upgradeViewControllerFactory = upgradeViewControllerFactory
        self.offlineViewControllerFactory = offlineViewControllerFactory
        self.tasks = tasks
    }

    public func create() -> AppInitializationViewController {
        // In the case that the app has been freshly installed or just been upgraded we want to make a call
        // to the app initialization service first. This call makes changes to the server that can be required
        // for all subsequent calls to succeed. In every other case, we want to be as performant as possible
        // and send out all requests at the same time.
        
        let initializer: AppInitializer = GBVersionTracking.isFirstLaunchForVersion()
            ? PrioritizedInitializer(tasks: tasks)
            : ConcurrentInitializer(tasks: tasks)
        
        return AppInitializationViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            upgradeViewControllerFactory: upgradeViewControllerFactory,
            offlineViewControllerFactory: offlineViewControllerFactory,
            initializer: initializer
        )
    }
}
