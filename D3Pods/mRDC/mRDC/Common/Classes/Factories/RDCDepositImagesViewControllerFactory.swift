//
//  RDCDepositImagesViewControllerFactory.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/3/18.
//

import Foundation
import Localization
import ComponentKit

final class RDCDepositImagesViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let rdcZoomingImageViewControllerFactory: RDCZoomingImageViewControllerFactory
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcZoomingImageViewControllerFactory: RDCZoomingImageViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcZoomingImageViewControllerFactory = rdcZoomingImageViewControllerFactory
    }
    
    func create(imageData: [RDCImageData], backCheckPressed: Bool) -> UIViewController {
        return RDCDepositImagesViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            imageData: imageData,
            rdcZoomingImageViewControllerFactory: rdcZoomingImageViewControllerFactory,
            backCheckPressed: backCheckPressed
        )
    }
    
}
