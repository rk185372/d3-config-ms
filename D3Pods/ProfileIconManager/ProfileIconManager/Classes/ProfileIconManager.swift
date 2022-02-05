//
//  ProfileIconManager.swift
//  ComponentKit
//
//  Created by Branden Smith on 8/9/19.
//

import Analytics
import CardControlApi
import CompanyAttributes
import ComponentKit
import Foundation
import InAppRatingApi
import Localization
import Logging
import Messages
import Permissions
import QRScanner
import RxSwift
import Session
import UIKit
import Utilities
import Web
import WebKit

public final class ProfileIconManager: ProfileIconCoordinator {
    private weak var viewController: UIViewController?

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
    private let bag: DisposeBag = DisposeBag()
    private let webProcessPool: WKProcessPool
    private let permissionsManager: PermissionsManager
    private let cardControl: CardControlManager
    private let qrScannerFactory: QRScannerViewControllerFactory
    private let profileIconService: ProfileIconService
    private let companyAttributesHolder: CompanyAttributesHolder
    
    public private(set) lazy var profileIconComponent: UIBarButtonItem = {
        let component = ProfileIconComponent(
            style: .plain,
            target: self,
            action: #selector(profileIconTouched(_:))
        )
        
        component.accessibilityIdentifier = "profileIconBarButtonItem"

        return component
    }()

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
        
        self.profileIconComponent.accessibilityTraits = UIAccessibilityTraits.button
        self.profileIconComponent.accessibilityLabel = self.l10nProvider.localize("userProfile.button.altText")
    }

    /// Sets up the ProfileIconManager to work for a particular view controller.
    /// This method must be called for the ProfileIconManager to properly govern
    /// ProfileIconActions.
    ///
    /// - Parameter controller: The view controller whos profile icon this instance manages.
    public func setupForViewController(_ controller: UIViewController) {
        self.viewController = controller
        updateCurrentIcon()
    }

    @objc private func profileIconTouched(_ sender: ProfileIconComponent) {
        showProfileOptionsActionSheet()
    }

    private func showProfileOptionsActionSheet() {
        let currentConsumerProfile: UserProfile? = userSession.userProfiles.first(where: { $0.profileType == "CONSUMER" })
        let firstName: String = currentConsumerProfile?.firstName ?? ""
        let lastName: String = currentConsumerProfile?.lastName ?? ""
        let lastLogin: String = currentConsumerProfile?.previousLogin ?? ""

        let alert = UIAlertController(
            title: "\(firstName) \(lastName)",
            message: (!lastLogin.isEmpty)
                ? l10nProvider.localize("userProfile.lastLogin", parameterMap: ["lastLogin": lastLogin])
                : nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("nav.my.profile"), style: .default) { _ in
                // This path is hard-coded as we always expect this to be here however,
                // If the href in the webComponents navigation.json changes this will not
                // work and will need to be changed to reflect the href in the navigation.json.
                self.showModalWebView(forComponentPath: WebComponentPath(path: "profile")) { [weak self] in
                    self?.updateCurrentIcon()
                }
            }
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("nav.profile.alert-settings"), style: .default) { _ in
                // This path is hard-coded as we always expect this to be here however,
                // If the href in the webComponents navigation.json changes this will not
                // work and will need to be changed to reflect the href in the navigation.json.
                self.showModalWebView(forComponentPath: WebComponentPath(path: "alert-management"))
            }
        )
        
        let preferencesFeature = Feature(path: "settings/preferences")
        let shouldShowPreferences = permissionsManager.isAccessible(feature: preferencesFeature)

        if shouldShowPreferences {
            // Only show this when at least one nested permissions also exist.This is the same check happening in web.
            let hasCategoriesPermission = permissionsManager.hasRole(role: "settings.categories", access: .read)
            let hasRulesPermission = permissionsManager.hasRole(role: "settings.rules", access: .read)
            let hasAccountsPermission = permissionsManager.hasRole(role: "settings.accounts", access: .read)

            // For the hasMobilePermission, You don't need this in 4.10
            //as this page doesnt include mobile yet. In 4.11 you will want to check the permission though
            let hasMobilePermission = permissionsManager.hasRole(role: "settings.mobile",access: .read)

            if hasCategoriesPermission || hasRulesPermission || hasMobilePermission || hasAccountsPermission {
                alert.addAction(
                    UIAlertAction(title: l10nProvider.localize("nav.profile.my-preferences"), style: .default) { _ in
                        self.showModalWebView(forComponentPath: WebComponentPath(path: "preferences"))
                    }
                )
            }
        }
        
        let shouldShowUserManagement = permissionsManager.hasRole(role: "settings.usermanagement")
        if shouldShowUserManagement {
            alert.addAction(
                UIAlertAction(title: l10nProvider.localize("nav.profile.user-management"), style: .default) { _ in
                    // This path is hard-coded as we always expect this to be here however,
                    // If the href in the webComponents navigation.json changes this will not
                    // work and will need to be changed to reflect the href in the navigation.json.
                    self.showModalWebView(forComponentPath: WebComponentPath(path: "user-management"))
                }
            )
        }

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("header.logout"), style: .default) { _ in
                // We post a notification here because the NotificationListener is subscribed
                // to this notification. The NotificationListener will set the session to nil.
                // The UserSession.session observable is being observed by the LogoutHandler which
                // will take care of telling the RootPresenter to transition to the auth page.
                NotificationCenter.default.post(name: .loggedOut, object: nil)
            }
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.cancel"), style: .cancel, handler: nil)
        )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.profileIconComponent.customView
                let bounds = self.profileIconComponent.customView?.bounds

                 // To visually center the arrow of the popover controller to the bottom middle of the profile
                 // icon, we tried setting bounds!.maxX / 2 but that did not work
                popoverController.sourceRect = CGRect(
                    x: bounds!.midX - (bounds!.midX / 10),
                    y: bounds!.maxY,
                    width: 0,
                    height: 0
                )
            }
        }
        
        viewController?.present(alert, animated: true, completion: nil)
    }

    /// Presents an instance of the web view modally.
    ///
    /// - Parameter url: The url to be loaded by the presented web view.
    private func showModalWebView(forComponentPath componentPath: WebComponentPath, onDismiss: (() -> Void)? = nil) {
        guard let webClient = try? webClientFactory.create(componentPath: componentPath) else { return }

        let webViewController = WebViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            webClient: webClient,
            isRootComponent: true,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            pdfPresenter: pdfPresenter,
            urlOpener: urlOpener,
            messageStatsManager: messageStatsManager,
            webViewExtensionsCache: webViewExtensionsCache,
            analyticsTracker: analyticsTracker,
            inAppRatingManager: inAppRatingManager,
            profileIconCoordinatorFactory: profileIconCoordinatorFactory(),
            isModal: true,
            webProcessPool: webProcessPool,
            cardControl: cardControl,
            webClientFactory: webClientFactory,
            qrScannerFactory: qrScannerFactory,
            postDismissAction: onDismiss
        )

        webViewController.navigationTextStyle = "navigationTitleOnDefault"
        webViewController.navigationStyle = "navigationBarOnDefault"
        webViewController.statusBarStyle = "statusBarOnDefault"

        let navigationController = UINavigationControllerComponent(
            rootViewController: webViewController
        )

        viewController?.present(navigationController, animated: true, completion: nil)
    }

    private func profileIconCoordinatorFactory() -> ProfileIconCoordinatorFactory {
        return ProfileIconManagerFactory(
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
    
    public func updateCurrentIcon() {
        guard let attributes = companyAttributesHolder.companyAttributes.value,
                attributes.boolValue(forKey: "settings.profile.avatar.enabled") else {
            return
        }
        profileIconService.getCurrentIcon().subscribe(onSuccess: { [weak self] image in
            (self?.profileIconComponent as? ProfileIconComponent)?.updateIcon(image)
        }, onError: { error in
            log.error(error.localizedDescription)
        }).disposed(by: bag)
    }
}
