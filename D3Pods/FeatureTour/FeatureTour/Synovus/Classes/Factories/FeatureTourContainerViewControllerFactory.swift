//
//  FeatureTourContainerViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/10/19.
//

import Foundation
import ComponentKit
import Localization

public final class FeatureTourContainerViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let featureTourContent: FeatureTourContent
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         featureTourContent: FeatureTourContent) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.featureTourContent = featureTourContent
    }
    
    public func create() -> UIViewController {
        return FeatureTourContainerViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            featureTourContent: featureTourContent
        )
    }
}
