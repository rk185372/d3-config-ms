//
//  PagingViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/14/19.
//

import Foundation
import Localization

public final class PagingViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    public func create(viewControllers: [UIViewController]) -> PagingViewController {
        return PagingViewController(
            viewControllers: viewControllers,
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }
}
