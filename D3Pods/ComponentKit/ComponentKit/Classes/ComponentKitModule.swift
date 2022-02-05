//
//  ComponentKitModule.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/17/18.
//

import Foundation
import Dip
import DependencyContainerExtension
import OpenLinkManager

public final class ComponentKitModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { ComponentConfig(l10nProvider: $0, componentStyleProvider: $1) }
        container.register { ComponentFactory(config: $0) }
        container.register {
            DisclosureViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                pdfPresenter: try container.resolve(),
                openLinkManager: try container.resolve(),
                externalWebViewControllerFactory: try container.resolve()
            )
        }
        container.register { ExternalWebViewControllerFactory(config: $0, device: $1, urlOpener: $2) }
        container.register(.singleton) {
            ComponentStyleContainer() as ComponentStyleProvider
        }
        container.register { PagingViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }
    }
}
