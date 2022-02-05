//
//  ProfileIconManagerModule.swift
//  ProfileIconManager
//
//  Created by Branden Smith on 8/9/19.
//

import DependencyContainerExtension
import Foundation
import Utilities

public final class ProfileIconManagerModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register {
            ProfileIconServiceItem(client: $0) as ProfileIconService
        }
        container.register {
            ProfileIconManagerFactory(
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve(),
                externalWebViewControllerFactory: try container.resolve(),
                messageStatsManager: try container.resolve(),
                webClientFactory: try container.resolve(),
                pdfPresenter: try container.resolve(),
                urlOpener: try container.resolve(),
                webViewExtensionsCache: try container.resolve(),
                analyticsTracker: try container.resolve(),
                inAppRatingManager: try container.resolve(),
                userSession: try container.resolve(),
                webProcessPool: try container.resolve(),
                permissionsManager: try container.resolve(),
                cardControl: try container.resolve(),
                qrScannerFactory: try container.resolve(),
                profileIconService: try container.resolve(),
                companyAttributesHolder: try container.resolve()
            ) as ProfileIconCoordinatorFactory
        }
    }
}
