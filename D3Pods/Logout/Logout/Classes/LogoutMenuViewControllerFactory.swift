//
//  LogoutMenuViewControllerFactory.swift
//  Logout
//
//  Created by Chris Carranza on 9/12/18.
//

import Foundation
import Utilities
import ComponentKit
import Localization
import Permissions

public final class LogoutMenuViewControllerFactory: ViewControllerFactory {
    
    private let companyConfig: ComponentConfig
    
    public init(config: ComponentConfig) {
        self.companyConfig = config
    }
    
    public func create() -> UIViewController {
        return LogoutMenuViewController(config: companyConfig)
    }
}

extension LogoutMenuViewControllerFactory: Permissioned {
    public var feature: Feature {
        return .logout
    }
}
