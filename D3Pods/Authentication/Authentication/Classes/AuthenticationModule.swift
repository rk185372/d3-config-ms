//
//  AuthenticationModule.swift
//  Accounts-iOS
//
//  Created by Chris Carranza on 3/28/19.
//

import Foundation
import Dip
import DependencyContainerExtension

public final class AuthenticationModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register(.singleton) { ChallengePersistenceHelper(authUserStore: $0,
                                                                    companyAttributesHolder: $1,
                                                                    biometricsHelper: $2)
        }
        container.register {
            ChallengeServiceItemFactory(
                client: $0,
                challengeServiceBridge: $1,
                networkInterceptor: { try! container.resolve() }
            ) as ChallengeServiceFactory
        }
        container.register { ChallengeServiceBridge(transformer: $0) }
        container.register {
            return AuthViewControllerFactory(
                componentConfig: try container.resolve(),
                challengeServiceFactory: try container.resolve(),
                mfaEnrollmentServiceFactory: try container.resolve(),
                authUserStore: try container.resolve(),
                persistenceHelper: try container.resolve(),
                biometricsHelper: try container.resolve(),
                biometricsAutoPromptManagerFactory: try container.resolve(),
                companyAttributes: try container.resolve(),
                bundle: try container.resolve(),
                userInteraction: try container.resolve(),
                analyticsTracker: try container.resolve(),
                restServer: try container.resolve(),
                uuid: try container.resolve(),
                inAppRatingManager: try container.resolve()
            )
        }
        container.register {
            MFAEnrollmentServiceItemFactory(
                client: $0,
                networkInterceptor: {try! container.resolve()}
            ) as MFAEnrollmentServiceFactory
        }
    }
}
