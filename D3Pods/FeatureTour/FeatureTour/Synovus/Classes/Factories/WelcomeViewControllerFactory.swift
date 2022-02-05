//
//  WelcomeViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/10/19.
//

import Foundation
import ComponentKit
import Localization

final class WelcomeViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(url: URL) -> FeatureTourContentViewController {
        return WelcomeViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            url: url
        )
    }
}
