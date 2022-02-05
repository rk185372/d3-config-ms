//
//  UpgradeViewControllerFactory.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/10/18.
//

import Foundation
import Localization
import ComponentKit
import Utilities

public final class UpgradeViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let urlOpener: URLOpener
    
    public init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider, urlOpener: URLOpener) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.urlOpener = urlOpener
    }
    
    func create(notification: UpgradeNotification) -> UpgradeViewController {
        return UpgradeViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            urlOpener: urlOpener,
            notification: notification
        )
    }
}
