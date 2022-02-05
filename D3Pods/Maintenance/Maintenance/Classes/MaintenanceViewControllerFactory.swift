//
//  MaintenanceViewControllerFactory.swift
//  Maintenance
//
//  Created by Andrew Watt on 8/3/18.
//

import UIKit
import ComponentKit
import Localization

public final class MaintenanceViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    public func create() -> MaintenanceViewController {
        return MaintenanceViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }
}
