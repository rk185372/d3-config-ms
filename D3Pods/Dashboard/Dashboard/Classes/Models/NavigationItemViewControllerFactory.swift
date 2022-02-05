//
//  NavigationItemViewControllerFactory.swift
//  D3 Banking
//
//  Created by Chris Carranza on 1/15/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import UIKit
import Utilities
import Permissions

public final class NavigationItemViewControllerFactory {
    private let permissionsManager: PermissionsManager
    private let viewControllerFactories: [NavigationItem: ViewControllerFactory & Permissioned]
    
    public init(permissionsManager: PermissionsManager,
                viewControllerFactories: [NavigationItem: ViewControllerFactory & Permissioned]) {
        self.permissionsManager = permissionsManager
        self.viewControllerFactories = viewControllerFactories
    }
    
    func create(navigationItem: NavigationItem) -> UIViewController? {
        guard let factory = viewControllerFactories[navigationItem], permissionsManager.isAccessible(feature: factory.feature) else {
            return nil
        }

        return factory.create()
    }
}
