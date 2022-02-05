//
//  PagingContentViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/25/19.
//

import Foundation
import ComponentKit
import Localization

final class PagingContentViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(viewControllers: [FeatureTourContentViewController]) -> FeatureTourContentViewController {
        return PagingContentViewController(
            viewControllers: viewControllers,
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }
}
