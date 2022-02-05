//
//  RemoteDepositViewControllerFactory.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import Foundation
import InAppRatingApi
import Localization
import ComponentKit
import Session
import Utilities

final class RDCDepositViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let rdcService: RDCService
    private let device: Device
    private let rdcConfirmationViewControllerFactory: RDCConfirmationViewControllerFactory
    private let rdcCaptureProvider: RDCCaptureProvider
    private let inAppRatingManager: InAppRatingManager
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcService: RDCService,
         device: Device,
         rdcConfirmationViewControllerFactory: RDCConfirmationViewControllerFactory,
         rdcCaptureProvider: RDCCaptureProvider,
         inAppRatingManager: InAppRatingManager) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcService = rdcService
        self.device = device
        self.rdcConfirmationViewControllerFactory = rdcConfirmationViewControllerFactory
        self.rdcCaptureProvider = rdcCaptureProvider
        self.inAppRatingManager = inAppRatingManager
    }
    
    func create() -> RDCDepositViewController {
        return RDCDepositViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            device: device,
            rdcConfirmationViewControllerFactory: rdcConfirmationViewControllerFactory,
            rdcDepositViewModel: RDCDepositViewModel(
                l10nProvider: l10nProvider,
                componentStyleProvider: componentStyleProvider,
                rdcService: rdcService,
                device: device,
                rdcCaptureProvider: rdcCaptureProvider
            ),
            inAppRatingManager: inAppRatingManager
        )
    }
}
