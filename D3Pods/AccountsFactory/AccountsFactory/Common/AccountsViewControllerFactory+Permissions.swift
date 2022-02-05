//
//  AccountsViewControllerFactory+Permissions.swift
//  AccountsFactory
//
//  Created by Andrew Watt on 10/19/18.
//

import Foundation
import Permissions

extension AccountsViewControllerFactory: Permissioned {
    public var feature: Feature {
        return .accounts
    }
}
