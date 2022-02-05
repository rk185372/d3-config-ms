//
//  EnableFeatureViewControllerFactory.swift
//  Enablement
//
//  Created by Chris Carranza on 6/6/18.
//

import Foundation
import Localization
import ComponentKit
import PostAuthFlowController

public final class EnableFeatureViewControllerFactory {
    
    let l10nProvider: L10nProvider
    let componentStyleProvider: ComponentStyleProvider
    let enableFeatureConfigurationFactory: EnableFeatureConfigurationFactory
    let enableFeatureDisclosureViewControllerFactory: DisclosureViewControllerFactory
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                enableFeatureConfigurationFactory: EnableFeatureConfigurationFactory,
                enableFeatureDisclosureViewControllerFactory: DisclosureViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.enableFeatureConfigurationFactory = enableFeatureConfigurationFactory
        self.enableFeatureDisclosureViewControllerFactory = enableFeatureDisclosureViewControllerFactory
    }
    
    public func create(configuration: EnableFeatureConfiguration, postAuthFlowController: PostAuthFlowController?) -> UIViewController {
        return EnableFeatureViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            configuration: configuration,
            enableFeatureDisclosureViewControllerFactory: enableFeatureDisclosureViewControllerFactory,
            postAuthFlowController: postAuthFlowController
        )
    }
    
    public func createWithFaceIdConfiguration(postAuthFlowController: PostAuthFlowController?) -> UIViewController {
        return create(
            configuration: enableFeatureConfigurationFactory.createFaceIDConfiguration(),
            postAuthFlowController: postAuthFlowController
        )
    }
    
    public func createWithTouchIdConfiguration(postAuthFlowController: PostAuthFlowController?) -> UIViewController {
        return create(
            configuration: enableFeatureConfigurationFactory.createTouchIDConfiguration(),
            postAuthFlowController: postAuthFlowController
        )
    }
    
    public func createWithSnapshotConfiguration(postAuthFlowController: PostAuthFlowController?) -> UIViewController {
        return create(
            configuration: enableFeatureConfigurationFactory.createSnapshotConfiguration(),
            postAuthFlowController: postAuthFlowController
        )
    }
}
