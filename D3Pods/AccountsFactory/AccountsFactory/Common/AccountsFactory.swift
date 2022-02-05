//
//  AccountsFactory.swift
//  AccountsFactory
//
//  Created by Andrew Watt on 10/8/18.
//

import Foundation
import Utilities
import Dip

public protocol AccountsFactory: ViewControllerFactory {
    init(dependencyContainer: DependencyContainer) throws
}
