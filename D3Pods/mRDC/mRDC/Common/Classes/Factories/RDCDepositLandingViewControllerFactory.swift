//
//  RDCDepositLandingViewControllerFactory.swift
//  mRDC
//
//  Created by Chris Carranza on 11/15/18.
//

import Foundation
import Localization
import ComponentKit
import InAppRatingApi

final class RDCDepositLandingViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let depositViewControllerFactory: RDCDepositViewControllerFactory
    private let inAppRatingManager: InAppRatingManager
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         depositViewControllerFactory: RDCDepositViewControllerFactory,
         inAppRatingManager: InAppRatingManager) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.depositViewControllerFactory = depositViewControllerFactory
        self.inAppRatingManager = inAppRatingManager
    }
    
    func create() -> UIViewController {
        return RDCDepositLandingViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            depositViewControllerFactory: depositViewControllerFactory,
            inAppRatingManager: inAppRatingManager
        )
    }
}
