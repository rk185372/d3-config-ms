//
//  AccountsNavigationControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/17/18.
//

import Foundation
import Dip
import Utilities

public final class AccountsNavigationControllerFactory: ViewControllerFactory {
    private let accountsViewControllerFactory: AccountsVCFactory
    
    public init(accountsViewControllerFactory: AccountsVCFactory) {
        self.accountsViewControllerFactory = accountsViewControllerFactory
    }
    
    public func create() -> UIViewController {
        return AccountsNavigationController(accountsViewControllerFactory: accountsViewControllerFactory)
    }
}
