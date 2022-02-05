//
//  TermsOfServiceViewControllerFactory.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/4/18.
//

import AppConfiguration
import ComponentKit
import Foundation
import Localization
import OpenLinkManager
import PostAuthFlowController
import Utilities

public final class TermsOfServiceViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let service: TermsOfServiceService
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager
    private let restServer: RestServer
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                service: TermsOfServiceService,
                pdfPresenter: PDFPresenter,
                openLinkManager: OpenLinkManager,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory,
                restServer: RestServer) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.service = service
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager
        self.restServer = restServer
    }
    
    public func create(termsOfService: TermsOfService, postAuthFlowController: PostAuthFlowController? = nil) -> UIViewController {
        return TermsOfServiceViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            termsOfService: termsOfService,
            service: service,
            postAuthFlowController: postAuthFlowController,
            pdfPresenter: pdfPresenter,
            openLinkManager: openLinkManager,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            restServer: restServer
        )
    }
}
