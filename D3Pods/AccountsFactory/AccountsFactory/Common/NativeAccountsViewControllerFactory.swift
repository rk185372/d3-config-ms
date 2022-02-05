//
//  NativeAccountsViewControllerFactory.swift
//  AccountsFactory
//
//  Created by Andrew Watt on 10/8/18.
//

import Foundation
import AccountsPresentation
import Utilities
import Dip

public final class NativeAccountsViewControllerFactory: AccountsFactory {
    private let factory: ViewControllerFactory
    
    public init(dependencyContainer: DependencyContainer) throws {
        self.factory = AccountsNavigationControllerFactory(accountsViewControllerFactory: try dependencyContainer.resolve())
    }
    
    public func create() -> UIViewController {
        return factory.create()
    }
}
