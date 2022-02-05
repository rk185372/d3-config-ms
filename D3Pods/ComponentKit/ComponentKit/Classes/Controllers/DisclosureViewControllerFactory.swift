//
//  DisclosureViewControllerFactory.swift
//  Enablement
//
//  Created by Chris Carranza on 8/13/18.
//

import Foundation
import Localization
import OpenLinkManager
import RxSwift
import Utilities

public final class DisclosureViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                pdfPresenter: PDFPresenter,
                openLinkManager: OpenLinkManager,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager
    }
    
    public func create(disclosure: Single<String>, errorTitle: String? = nil, errorMessage: String? = nil) -> DisclosureViewController {
        return DisclosureViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            disclosure: disclosure,
            errorTitle: errorTitle,
            errorMessage: errorMessage,
            pdfPresenter: pdfPresenter,
            openLinkManager: openLinkManager,
            externalWebViewControllerFactory: externalWebViewControllerFactory
        )
    }
}
