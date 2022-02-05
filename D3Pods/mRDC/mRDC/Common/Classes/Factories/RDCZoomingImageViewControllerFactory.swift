//
//  RDCZoomingImageViewControllerFactory.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/6/18.
//

import Foundation
import UIKit
import Localization
import ComponentKit
import Session
import Utilities

final class RDCZoomingImageViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(image: UIImage) -> UIViewController {
        return RDCZoomingImageViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            image: image
        )
    }
}
