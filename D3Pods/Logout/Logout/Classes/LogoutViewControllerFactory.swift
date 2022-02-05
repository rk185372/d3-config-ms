//
//  LogoutViewControllerFactory.swift
//  LogoutViewController
//
//  Created by Chris Carranza on 9/12/18.
//

import Foundation
import Utilities
import ComponentKit
import Localization
import Session

public final class LogoutViewControllerFactory {
    
    private let companyConfig: ComponentConfig
    private let logoutService: LogoutService
    private let sessionService: SessionService
    
    public init(config: ComponentConfig,
                logoutService: LogoutService,
                sessionService: SessionService) {
        self.companyConfig = config
        self.logoutService = logoutService
        self.sessionService = sessionService
    }
    
    public func create() -> LogoutViewController {
        return LogoutViewController(
            config: companyConfig,
            logoutService: logoutService,
            sessionService: sessionService
        )
    }
}
