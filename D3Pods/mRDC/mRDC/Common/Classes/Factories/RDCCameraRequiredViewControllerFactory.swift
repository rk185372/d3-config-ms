//
//  RDCCameraRequiredViewControllerFactory.swift
//  mRDC
//
//  Created by Chris Carranza on 10/12/18.
//

import Foundation
import Localization
import ComponentKit

final class RDCCameraRequiredViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create() -> UIViewController {
        return RDCCameraRequiredViewController(l10nProvider: l10nProvider, componentStyleProvider: componentStyleProvider)
    }
}
