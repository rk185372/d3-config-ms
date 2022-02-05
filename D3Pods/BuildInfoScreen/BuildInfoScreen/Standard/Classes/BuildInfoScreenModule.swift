//
//  BuildInfoScreenModule.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 12/17/18.
//

import DependencyContainerExtension
import Dip
import Foundation
import Utilities

public final class BuildInfoScreenModule: DependencyContainerModule {
    internal static weak var currentDependencyContainer: DependencyContainer?

    public static func provideDependencies(to container: DependencyContainer) {
        currentDependencyContainer = container

        container.register {
            ThemeServiceItem(client: $0) as ThemeService
        }

        container.register {
            L10nServiceItem(client: $0) as L10nService
        }

        container.register(.singleton) {
            BuildInfoViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                themeService: $2,
                l10nService: $3,
                buildInfoScreenState: $4
            )
        }

        container.register(.singleton) {
            BuildInfoScreenState(translatesL10n: true, usesLocalExtensions: true)
        }
    }
}
