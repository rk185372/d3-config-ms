//
//  ProfileIconManagerFactory.swift
//  ProfileIconManager
//
//  Created by Branden Smith on 8/12/19.
//

import Analytics
import CompanyAttributes
import ComponentKit
import Foundation
import InAppRatingApi
import Localization
import Messages
import Session
import Utilities
import Web
import WebKit
import Permissions
import CardControlApi
import QRScanner

public final class ProfileIconManagerFactory: ProfileIconCoordinatorFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let messageStatsManager: MessageStatsManager
    private let webClientFactory: WebClientFactory
    private let pdfPresenter: PDFPresenter
    private let urlOpener: URLOpener
    private let webViewExtensionsCache: WebViewExtensionsCache
    private let analyticsTracker: AnalyticsTracker
    private let inAppRatingManager: InAppRatingManager
    private let userSession: UserSession
    private let webProcessPool: WKProcessPool
    private let permissionsManager: PermissionsManager
    private let cardControl: CardControlManager
    private let qrScannerFactory: QRScannerViewControllerFactory
    private let profileIconService: ProfileIconService
    private let companyAttributesHolder: CompanyAttributesHolder
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory,
                messageStatsManager: MessageStatsManager,
                webClientFactory: WebClientFactory,
                pdfPresenter: PDFPresenter,
                urlOpener: URLOpener,
                webViewExtensionsCache: WebViewExtensionsCache,
                analyticsTracker: AnalyticsTracker,
                inAppRatingManager: InAppRatingManager,
                userSession: UserSession,
                webProcessPool: WKProcessPool,
                permissionsManager: PermissionsManager,
                cardControl: CardControlManager,
                qrScannerFactory: QRScannerViewControllerFactory,
                profileIconService: ProfileIconService,
                companyAttributesHolder: CompanyAttributesHolder) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.messageStatsManager = messageStatsManager
        self.webClientFactory = webClientFactory
        self.pdfPresenter = pdfPresenter
        self.urlOpener = urlOpener
        self.webViewExtensionsCache = webViewExtensionsCache
        self.analyticsTracker = analyticsTracker
        self.inAppRatingManager = inAppRatingManager
        self.userSession = userSession
        self.webProcessPool = webProcessPool
        self.permissionsManager = permissionsManager
        self.cardControl = cardControl
        self.qrScannerFactory = qrScannerFactory
        self.profileIconService = profileIconService
        self.companyAttributesHolder = companyAttributesHolder
    }

    public func create() -> ProfileIconCoordinator {
        return ProfileIconManager(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            messageStatsManager: messageStatsManager,
            webClientFactory: webClientFactory,
            pdfPresenter: pdfPresenter,
            urlOpener: urlOpener,
            webViewExtensionsCache: webViewExtensionsCache,
            analyticsTracker: analyticsTracker,
            inAppRatingManager: inAppRatingManager,
            userSession: userSession,
            webProcessPool: webProcessPool,
            permissionsManager: permissionsManager,
            cardControl: cardControl,
            qrScannerFactory: qrScannerFactory,
            profileIconService: profileIconService,
            companyAttributesHolder: companyAttributesHolder
        )
    }
}
