//
//  SessionExpirationWarningManagerFactory.swift
//  SessionExpiration
//
//  Created by Chris Carranza on 12/10/18.
//

import Foundation
import Navigation
import RxSwift
import Utilities
import UserInteraction

public final class SessionExpirationWarningManagerFactory {
    private let sessionExpirationManagerFactory: SessionExpirationManagerFactory
    private let warningVCFactory: SessionExpirationWarningVCFactory
    private let userInteraction: UserInteraction
    
    init(sessionExpirationManagerFactory: SessionExpirationManagerFactory,
         warningVCFactory: SessionExpirationWarningVCFactory,
         userInteraction: UserInteraction) {
        self.sessionExpirationManagerFactory = sessionExpirationManagerFactory
        self.warningVCFactory = warningVCFactory
        self.userInteraction = userInteraction
    }
    
    public func create() -> SessionExpirationWarningManager {
        return SessionExpirationWarningManager(
            sessionExpirationManager: sessionExpirationManagerFactory.create(),
            warningVCFactory: warningVCFactory,
            userInteraction: userInteraction
        )
    }
}
