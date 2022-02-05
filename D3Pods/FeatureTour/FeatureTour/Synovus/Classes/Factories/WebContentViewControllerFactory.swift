//
//  WebContentViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 2/4/19.
//

import Foundation
import ComponentKit
import Localization

final class WebContentViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(url: URL) -> WebContentViewController {
        return WebContentViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            url: url
        )
    }
}
