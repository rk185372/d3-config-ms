//
//  RDCConfirmationViewControllerFactory.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/28/18.
//

import ComponentKit
import Foundation
import Localization
import OpenLinkManager
import Session
import Utilities

final class RDCConfirmationViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let rdcService: RDCService
    private let rdcSuccessViewControllerFactory: RDCSuccessViewControllerFactory
    private let rdcDepositErrorViewControllerFactory: RDCDepositErrorViewControllerFactory
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcService: RDCService,
         rdcSuccessViewControllerFactory: RDCSuccessViewControllerFactory,
         rdcDepositErrorViewControllerFactory: RDCDepositErrorViewControllerFactory,
         pdfPresenter: PDFPresenter,
         openLinkManager: OpenLinkManager,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcService = rdcService
        self.rdcSuccessViewControllerFactory = rdcSuccessViewControllerFactory
        self.rdcDepositErrorViewControllerFactory = rdcDepositErrorViewControllerFactory
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager
    }
    
    func create(request: RDCRequest, displayMessages: [String]) -> RDCConfirmationViewController {
        return RDCConfirmationViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            rdcRequest: request,
            rdcService: rdcService,
            rdcSuccessViewControllerFactory: rdcSuccessViewControllerFactory,
            rdcDepositErrorViewControllerFactory: rdcDepositErrorViewControllerFactory,
            displayMessages: displayMessages,
            pdfPresenter: pdfPresenter,
            openLinkManager: openLinkManager,
            externalWebViewControllerFactory: externalWebViewControllerFactory
        )
    }
}
