//
//  RDCDepositErrorViewControllerFactory.swift
//  mRDC
//
//  Created by Chris Carranza on 11/1/18.
//

import Foundation
import ComponentKit
import Localization

final class RDCDepositErrorViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(responseError: RDCResponse) -> RDCDepositErrorViewController {
        return RDCDepositErrorViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            responseError: responseError
        )
    }
}
