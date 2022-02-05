//
//  WebAccountsViewControllerFactory.swift
//  AccountsFactory
//
//  Created by Andrew Watt on 10/8/18.
//

import Foundation
import Web
import Dip
import Utilities

public final class WebAccountsViewControllerFactory: AccountsFactory {
    private let factory: ViewControllerFactory
    
    public init(dependencyContainer container: DependencyContainer) throws {
        let navigation: WebComponentNavigation = try container.resolve(tag: "AccountsWebComponentNavigation")

        self.factory = try WebComponentViewControllerFactory(
            l10nProvider: try container.resolve(),
            componentStyleProvider: try container.resolve(),
            permissionsManager: try container.resolve(),
            webViewControllerFactory: try container.resolve(),
            navigation: navigation,
            userSession: try container.resolve()
        )
    }
    
    public func create() -> UIViewController {
        return factory.create()
    }
}
