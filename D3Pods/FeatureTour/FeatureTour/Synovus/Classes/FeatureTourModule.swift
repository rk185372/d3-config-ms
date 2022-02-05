//
//  FeatureTourModule.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/10/19.
//

import Foundation
import Dip
import DependencyContainerExtension

public final class FeatureTourModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register {
            FeatureTourContainerViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                featureTourContent: $2
            )
        }
        container.register { WelcomeViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }
        container.register { FeatureTourPresentable(featureTourContainerViewControllerFactory: $0, featureTourContent: $1) }
        container.register { SplashViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }
        container.register { PagingContentViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }
        container.register(.singleton) {
            FeatureTourContent(
                splashViewControllerFactory: try container.resolve(),
                welcomeViewControllerFactory: try container.resolve(),
                pagingContentViewControllerFactory: try container.resolve(),
                completeViewControllerFactory: try container.resolve(),
                webContentViewControllerFactory: try container.resolve(),
                companyAttributesHolder: try container.resolve(),
                userDefaults: try container.resolve(),
                screen: try container.resolve()
            )
        }
        container.register {
            CompleteViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1
            )
        }
        container.register {
            WebContentViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1)
        }
    }
}
