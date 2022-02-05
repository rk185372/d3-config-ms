//
//  RDCDepositTransactionDetailViewControllerFactory.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/3/18.
//

import Foundation
import Localization
import ComponentKit
import Utilities

final class RDCDepositTransactionDetailViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let rdcService: RDCService
    private let device: Device
    private let rdcDepositImagesViewControllerFactory: RDCDepositImagesViewControllerFactory
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcService: RDCService,
         device: Device,
         rdcDepositImagesViewControllerFactory: RDCDepositImagesViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcService = rdcService
        self.device = device
        self.rdcDepositImagesViewControllerFactory = rdcDepositImagesViewControllerFactory
    }
    
    func create(depositTransaction: DepositTransaction) -> UIViewController {
        return RDCDepositTransactionDetailViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            rdcService: rdcService,
            device: device,
            rdcDepositImagesViewControllerFactory: rdcDepositImagesViewControllerFactory,
            depositTransaction: depositTransaction
        )
    }
}
