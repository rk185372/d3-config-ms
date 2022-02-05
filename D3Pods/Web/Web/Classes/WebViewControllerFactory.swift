//
//  WebViewControllerFactory.swift
//  Web
//
//  Created by Andrew Watt on 6/28/18.
//

import UIKit
import Utilities
import Localization
import CardControlApi
import ComponentKit
import Network
import Messages
import Analytics
import InAppRatingApi
import WebKit
import QRScanner

public final class WebViewControllerFactory {
    private let l10NProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let webClientFactory: WebClientFactory
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let pdfPresenter: PDFPresenter
    private let urlOpener: URLOpener
    private let messageStatsManager: MessageStatsManager
    private let webViewExtensionsCache: WebViewExtensionsCache
    private let analyticsTracker: AnalyticsTracker
    private let inAppRatingManager: InAppRatingManager
    private let profileIconCoordinatorFactory: ProfileIconCoordinatorFactory
    private let webProcessPool: WKProcessPool
    private let cardControl: CardControlManager
    private let qrScannerFactory: QRScannerViewControllerFactory
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                webClientFactory: WebClientFactory,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory,
                pdfPresenter: PDFPresenter,
                urlOpener: URLOpener,
                messageStatsManager: MessageStatsManager,
                webViewExtensionsCache: WebViewExtensionsCache,
                analyticsTracker: AnalyticsTracker,
                inAppRatingManager: InAppRatingManager,
                profileIconCoordinatorFactory: ProfileIconCoordinatorFactory,
                webProcessPool: WKProcessPool,
                cardControl: CardControlManager,
                qrScannerFactory: QRScannerViewControllerFactory) {
        self.l10NProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.webClientFactory = webClientFactory
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.pdfPresenter = pdfPresenter
        self.urlOpener = urlOpener
        self.messageStatsManager = messageStatsManager
        self.webViewExtensionsCache = webViewExtensionsCache
        self.analyticsTracker = analyticsTracker
        self.inAppRatingManager = inAppRatingManager
        self.profileIconCoordinatorFactory = profileIconCoordinatorFactory
        self.webProcessPool = webProcessPool
        self.cardControl = cardControl
        self.qrScannerFactory = qrScannerFactory
    }

    func create(componentPath: WebComponentPath, isRootComponent: Bool, showsUserProfile: Bool = false) throws -> WebViewController {
        let webClient = try webClientFactory.create(componentPath: componentPath)
        return WebViewController(
            l10nProvider: l10NProvider,
            componentStyleProvider: componentStyleProvider,
            webClient: webClient,
            isRootComponent: isRootComponent,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            pdfPresenter: pdfPresenter,
            urlOpener: urlOpener,
            messageStatsManager: messageStatsManager,
            webViewExtensionsCache: webViewExtensionsCache,
            analyticsTracker: analyticsTracker,
            inAppRatingManager: inAppRatingManager,
            profileIconCoordinatorFactory: profileIconCoordinatorFactory,
            webProcessPool: webProcessPool,
            cardControl: cardControl,
            webClientFactory: webClientFactory,
            qrScannerFactory: qrScannerFactory
        )
    }
}
