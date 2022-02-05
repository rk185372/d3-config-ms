//
//  SessionExpirationModule.swift
//  SessionExpiration
//
//  Created by Chris Carranza on 12/14/18.
//

import Foundation
import UserInteraction
import Dip
import DependencyContainerExtension
import CompanyAttributes

public final class SessionExpirationModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register(.singleton) { SessionExpirationWarningVCFactory(l10nProvider: $0, styleProvider: $1) }
        container.register { SessionExpirationManagerFactory(userInteraction: $0, companyAttributes: $1) }
        container.register {
            SessionExpirationWarningManagerFactory(
                sessionExpirationManagerFactory: $0,
                warningVCFactory: $1,
                userInteraction: $2
            )
        }
    }
}
