//
//  SplashViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import Foundation
import ComponentKit
import Localization

final class SplashViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(backgroundImage: UIImage, textImage: UIImage) -> FeatureTourContentViewController {
        return SplashViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            backgroundImage: backgroundImage,
            textImage: textImage
        )
    }
}
