//
//  CompleteViewControllerFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/31/19.
//

import Foundation
import ComponentKit
import Localization

final class CompleteViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(backgroundImage: UIImage, logoImage: UIImage, taglineImage: UIImage) -> CompleteViewController {
        return CompleteViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            backgroundImage: backgroundImage,
            logoImage: logoImage,
            taglineImage: taglineImage
        )
    }
}
