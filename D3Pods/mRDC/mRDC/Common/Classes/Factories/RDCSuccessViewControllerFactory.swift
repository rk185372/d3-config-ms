//
//  RDCSuccessViewControllerFactory.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/29/18.
//

import Foundation
import Localization
import ComponentKit
import Session
import Utilities

final class RDCSuccessViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    func create(request: RDCRequest, response: RDCResponse) -> RDCSuccessViewController {
        return RDCSuccessViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            request: request,
            response: response
        )
    }
}
