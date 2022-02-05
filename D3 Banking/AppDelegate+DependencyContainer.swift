//
//  AppDelegate+DependencyContainer.swift
//  D3 Banking
//
//  Created by Chris Carranza on 6/12/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import APITransformer
import AccountsFactory
import AccountsPresentation
import AkamaiChallengeNetworkInterceptor
import Alamofire
import Analytics
import AppConfiguration
import AppInitialization
import AuthChallengeNetworkInterceptorApi
import AuthFlow
import Authentication
import Biometrics
import BuildInfoScreen
import CardControl
import CardControlApi
import CompanyAttributes
import ComponentKit
import D3Accounts
import D3Contacts
import Dashboard
import DependencyContainerExtension
import DeviceDescriptionChallengeNetworkInterceptor
import DeviceDescriptionEnablementNetworkInterceptor
import DeviceInfoService
import Dip
import EDocs
import EmailVerification
import Enablement
import EnablementNetworkInterceptorApi
import FeatureTour
import FirebaseAnalyticsD3
import Foundation
import InAppRating
import LegalContent
import Localization
import LocalizationData
import Locations
import LocationsPresentation
import LogAnalytics
import Logging
import Logout
import Maintenance
import MatomoAnalytics
import Messages
import Navigation
import Network
import Offline
import OpenLinkManager
import OutOfBand
import Permissions
import PostAuthFlow
import PostAuthFlowController
import ProfileIconManager
import QRScanner
import RequestTransformer
import RootViewController
import RxSwift
import SecurityQuestions
import Session
import SessionExpiration
import Snapshot
import SnapshotPresentation
import SnapshotService
import TermsOfService
import ThreatMetrixChallengeNetworkInterceptor
import Transactions
import UserInteraction
import UserNotifications
import Utilities
import Web
import WebKit
import mRDC

extension AppDelegate {
    func setupDependencyContainer() {
        dependencyContainer = DependencyContainer { container in
            container.register(.singleton) { Application.current() }
            container.register { UIApplication.shared }
            container.register(.singleton) {
                Device.current(application: $0, carrier: Device.currentCarrier(), uuid: $1)
            }
            container.register(.singleton) { UserDefaults(suiteName: AppConfiguration.applicationGroup)! }
            container.register { D3UUID(userDefaults: $0) }
            container.register(.singleton) { RootViewController() }
            container.register(.singleton) { () -> RestServer in
                var restServer: RestServer = AppConfiguration.restServer
                #if DEBUG
                if let testingUrl = ProcessInfo.processInfo.environment["testingURL"] {
                    restServer = RestServer(url: URL(string: testingUrl)!)
                }
                #endif
                return restServer
            }
            container.register { D3ClientRequestAdapter(uuid: $0, userSession: $1) as RequestAdapter }
            container.register(.singleton) { Client(restServer: $0, requestAdapter: $1, requestTransformer: $2) as ClientProtocol }
            container.register(.singleton) { ReachabilityMonitor(restServer: $0) }
            container.register { _ -> ThemeLoader in
                #if DEBUG
                if let testingUrl = ProcessInfo.processInfo.environment["testingURL"],
                    ProcessInfo.processInfo.arguments.contains("UI-Testing-Provides-Theme") {
                    return NetworkThemeLoader(baseUrl: URL(string: testingUrl)!, path: "theme/json") as ThemeLoader
                }
                #endif
                
                return FileThemeLoader(fileUrl: #fileLiteral(resourceName: "Themes.json")) as ThemeLoader
            }
            
            //These lines of code is used to parse attributes from web theme config
            container.register { _ -> WebThemeLoader in
                #if DEBUG
                if let testingUrl = ProcessInfo.processInfo.environment["testingURL"],
                    ProcessInfo.processInfo.arguments.contains("UI-Testing-Provides-Theme") {
                    return NetworkWebThemeLoader(baseUrl: URL(string: testingUrl)!, path: "webtheme/json") as WebThemeLoader
                }
                #endif
                
                let url = WebBundle.bundle.url(forResource: "theme", withExtension: "json")!
                return WebFileThemeLoader(fileUrl: url) as WebThemeLoader
            }
            
            container.register(.singleton) { ConfigurationSettings() }
            container.register(.singleton) { _ -> ThemeParser in
                let parser = ThemeParser(
                    loader: try container.resolve(),
                    styleProvider: try container.resolve(),
                    webLoader: try container.resolve(),
                    configurationSettings: try container.resolve()
                )
                parser.parse()
                return parser
            }

            container.register(.singleton) { _ -> ThemeColors in
                let parser: ThemeParser = try container.resolve()
                return parser.themeColors
            }

            container.register(.eagerSingleton) { (client: ClientProtocol) -> L10nProvider in
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("UI-Testing-Provides-L10n") {
                    return TestL10n(client: client) as L10nProvider
                }
                #endif
                
                let l10n = L10n()

                l10n.loadLocalizations(
                    resources: LocalizationDataProvider().ConsumerLocalizableData(),
                    completion: nil
                )

                return l10n as L10nProvider
            }
            container.register(.eagerSingleton) { (application: D3UIApplication) in
                AppUserInteraction(touchEvents: application.rx.touchEvents) as UserInteraction
            }
            container.register { OpenLinkManager() }
            
            container.register {
                return FeatureTourViewControllerFactoryItem(l10nProvider: $0) as FeatureTourViewControllerFactory
            }
            
            container.register {
                return FeatureTourServiceItem(client: $0) as FeatureTourService
            }
            
            container.register {
                return DashboardLandingFlowFactoryItem(factory: $0,
                                                       featureTourService: $1,
                                                       companyAttributesHolder: $2) as DashboardLandingFlowFactory
            }
            
            container.register {
                return DashboardViewControllerFactory(
                    config: try container.resolve(),
                    monitor: try container.resolve(),
                    messageStatsManager: try container.resolve(),
                    componentStyleProvider: try container.resolve(),
                    sessionExpirationWarningManagerFactory: try container.resolve(),
                    inAppRatingManager: try container.resolve(),
                    landingFlowFactory: try container.resolve()
                )
            }
            
            container.register(.singleton) {
                CompositeAnalyticsTracker(
                    trackers: [
                        LogAnalyticsTracker(),
                        FirebaseAnalyticsTracker(),
                        MatomoAnalyticsTracker(url: AppConfiguration.analyticsUrl, siteId: AppConfiguration.analyticsSiteId)
                    ]
                )
            }.implements(AnalyticsTracker.self)
            container.register(.eagerSingleton) { ScreenAnalyticsTracker(tracker: $0) }
            container.register { SnapshotServiceItem(client: $0) as SnapshotService }

            container.register { try AccountsViewControllerFactory(dependencyContainer: container) }

            container.register(.eagerSingleton) { WKProcessPool() }
            
            container.register { () -> WebClientFactory in

                return WebClientFactory(
                    client: try container.resolve(),
                    device: try container.resolve(),
                    userSession: try container.resolve(),
                    biometricsHelper: try container.resolve(),
                    userStore: try container.resolve(),
                    startupHolder: try container.resolve()
                )
            }
            
            container.register {
                return WebViewControllerFactory(
                    l10nProvider: try container.resolve(),
                    componentStyleProvider: try container.resolve(),
                    webClientFactory: try container.resolve(),
                    externalWebViewControllerFactory: try container.resolve(),
                    pdfPresenter: try container.resolve(),
                    urlOpener: try container.resolve(),
                    messageStatsManager: try container.resolve(),
                    webViewExtensionsCache: try container.resolve(),
                    analyticsTracker: try container.resolve(),
                    inAppRatingManager: try container.resolve(),
                    profileIconCoordinatorFactory: try container.resolve(),
                    webProcessPool: try container.resolve(),
                    cardControl: try container.resolve(),
                    qrScannerFactory: try container.resolve()
                )
            }

            container.register { (userSession: UserSession, companyAttributes: CompanyAttributesHolder) -> PermissionsManager in
                let manager = PermissionsManager(rules: WebComponent.rules())
                _ = userSession.rx.roles.bind { manager.roles = $0 }
                _ = userSession.rx.rdcAllowed.bind { manager.rdcAllowed = $0 }
                _ = companyAttributes.companyAttributes.bind { attributes in
                    manager.locationsAllowed = attributes?.value(forKey: "locations.enabled") ?? false
                    manager.cardControlsAllowed = attributes?.value(forKey: "accounts.cardControls.advanced.enabled") ?? false
                    manager.financialWellnessPermissions = FinancialWellnessPermisionsItem(attributes: attributes)
                }

                return manager
            }
            container.register(tag: "AccountsWebComponentNavigation") { WebComponent.accounts }
            container.register {
                NavigationProvider(
                    l10nProvider: try container.resolve(),
                    styleProvider: try container.resolve(),
                    statsManager: try container.resolve(),
                    permissionsManager: try container.resolve()
                )
            }

            container.register(.singleton) { PushNotificationTokenHandler() }
            container.register(.singleton) { AppPushNotificationDelegate(tokenHandler: $0, cardControlPushHandler: $1) }
            container.register {
                SessionService(client: $0, device: $1, userSession: $2, pushNotificationTokenHandler: $3)
            }
            container.register(.singleton) { UserSession() }
            container.register(.singleton) { EnablementNetworkInterceptorItem() }
            container.register { EnablementServiceItem(client: $0, networkInterceptor: $1) as EnablementService }
            container.register { LegalContentServiceItem(client: $0) as LegalContentService }
            container.register { DeviceInfoService(client: $0, uuid: $1) }
            container.register {
                EnablementConfigurationServices(
                    enablementService: $0,
                    legalContentService: $1,
                    deviceInfoService: $2,
                    biometricsHelper: $3
                )
            }
            container.register {
                EnableFeatureConfigurationFactory(
                    l10nProvider: $0,
                    componentStyleProvider: $1,
                    enablementConfigurationServices: $2,
                    userDefaults: $3,
                    userStore: $4
                )
            }
            container.register {
                EnableFeatureViewControllerFactory(
                    l10nProvider: $0,
                    componentStyleProvider: $1,
                    enableFeatureConfigurationFactory: $2,
                    enableFeatureDisclosureViewControllerFactory: $3
                )
            }
            container.register {
                TermsOfServiceServiceItem(client: $0, device: $1) as TermsOfServiceService
            }
            container.register {
                TermsOfServiceViewControllerFactory(
                    l10nProvider: $0,
                    componentStyleProvider: $1,
                    service: $2,
                    pdfPresenter: try container.resolve(),
                    openLinkManager: try container.resolve(),
                    externalWebViewControllerFactory: try container.resolve(),
                    restServer: try container.resolve()
                )
            }
            
            container.register {
                OOBServiceItem(client: $0, device: $1) as OOBService
            }
            
            container.register {
                return OOBViewControllerFactory(
                    service: $1, config: $0, userSession: $2, userInteraction: $3, companyAttribute: $4
                )
            }
           
            container.register(.singleton) { StartupHolder() }
                .implements(CompanyAttributesHolder.self)
            container.register { CompanyAttributesProvider(companyAttributesHolder: $0) }
            container.register(.singleton) { Bundle.main }

            container.register { SnapshotViewControllerFactory(config: $0, service: $1, device: $2, configurationSettings: $3) }
            container.register { LocationsNavigationControllerFactory(rootContainer: container) }
            container.register { AuthDialogControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }
            container.register { PDFPresenter() }
            container.register {
                return FlowAuthPresenter(
                    snapshotViewControllerFactory: try container.resolve(),
                    locationsViewControllerFactory: try container.resolve() as LocationsNavigationControllerFactory,
                    urlOpener: try container.resolve(),
                    pdfPresenter: try container.resolve(),
                    externalWebViewControllerFactory: try container.resolve(),
                    authDialogControllerFactory: try container.resolve()
                ) as AuthPresenter
            }
            container.register {
                return AuthFlowNavigationControllerFactory(
                    authViewControllerFactory: try container.resolve(),
                    sessionService: try container.resolve(),
                    appInitializationService: try container.resolve(),
                    startupHolder: try container.resolve(),
                    postAuthFlowFactory: try container.resolve(),
                    presenter: try container.resolve(),
                    biometricsHelper: try container.resolve(),
                    l10nProvider: try container.resolve()
                )
            }

            container.register {
                AppInitializationServiceItem(client: $0, device: $1) as AppInitializationService
            }
            container.register { SystemURLOpener() as URLOpener }
            container.register { UpgradeViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1, urlOpener: $2) }
            container.register { OfflineViewControllerFactory(config: $0, monitor: $1) }
            container.register { StartupTask(service: $0, startupHolder: $1) }
            container.register { UpgradeCheckTask(service: $0) }
            container.register { BiometricAuthTokenTask(biometricsHelper: $0) }
            container.register { UserDataMigrationTask(userDefaults: $0, authUserStore: $1) }
            container.register {
                return AppInitializationViewControllerFactory(
                    l10nProvider: try container.resolve(),
                    componentStyleProvider: try container.resolve(),
                    upgradeViewControllerFactory: try container.resolve(),
                    offlineViewControllerFactory: try container.resolve(),
                    tasks: [
                        try container.resolve() as UserDataMigrationTask,
                        try container.resolve() as BiometricAuthTokenTask,
                        try container.resolve() as StartupTask,
                        try container.resolve() as UpgradeCheckTask
                    ]
                )
            }

            container.register { MaintenanceViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1) }

            container.register { L10nTranslator(provider: $0) }

            container.register { RequestSender() }
            container.register { APITransformer(l10nTranslator: $0, companyAttributesProvider: $1, requestSender: $2) }

            container.register { AppInitializationPresentable(factory: $0) }
            container.register { AuthPresentable(factory: $0, sessionService: $1) }
            container.register { DashboardPresentable(factory: $0) }
            container.register { MaintenancePresentable(factory: $0) }
            container.register(.singleton) { _ -> RootPresenter in
                return RootViewControllerPresenter(
                    rootViewController: try container.resolve(),
                    presentables: RootViewControllerPresenter.Presentables(
                        initialization: try container.resolve() as AppInitializationPresentable,
                        featureTour: try container.resolve() as FeatureTourPresentable,
                        authentication: try container.resolve() as AuthPresentable,
                        dashboard: try container.resolve() as DashboardPresentable,
                        maintenance: try container.resolve() as MaintenancePresentable,
                        logout: try container.resolve() as LogoutPresentable
                    ),
                    application: try container.resolve(),
                    navigationProvider: try container.resolve(),
                    dependencyContainer: container,
                    buildInfoViewControllerFactory: try? container.resolve() as BuildInfoViewControllerFactory
                ) as RootPresenter
            }

            container.register {
                return EDocsViewControllerFactory(
                    config: $0,
                    edocsService: $1,
                    companyAttributes: $2
                )
            }
            container.register { EDocsServiceItem(client: $0) as EDocsService }
            container.register { _ -> PostAuthFlowFactory in
                let setupStepFactories: [SetupStep: PostAuthViewControllerFactory] = [
                    .securityQuestion: try! container.resolve() as SecurityQuestionsViewControllerFactory,
                    .verifyEmail: try! container.resolve() as EmailVerificationViewControllerFactory
                ]

                return PostAuthFlowFactory(
                    termsOfServiceFactory: try container.resolve(),
                    setupStepFactories: setupStepFactories,
                    companyAttributesHolder: try container.resolve(),
                    userDefaults: try container.resolve(),
                    enableFeatureViewControllerFactory: try container.resolve(),
                    edocsViewControllerFactory: try container.resolve(),
                    edocsConfigurationFactory: try container.resolve(),
                    biometricsHelper: try container.resolve(),
                    userStore: try container.resolve(),
                    oobFactory: try container.resolve(),
                    userSession: try container.resolve()
                )
            }

            container.register(.singleton) { NotificationListener(presenter: $0, userSession: $1) }

            container.register(.singleton) {
                ApplicationRoot(
                    rootPresenter: $0,
                    notificationListener: $1,
                    pushNotificationDelegate: $2
                )
            }
            
            container.register(.singleton) { MessagesServiceItem(client: $0) }.implements(MessagesService.self)
            container.register(.singleton) { (serviceItem: MessagesService, userInteraction: UserInteraction, userSession: UserSession) in
                MessageStatsManager(
                    serviceItem: serviceItem,
                    touchObservable: userInteraction.userInteractions,
                    userSession: userSession
                )
            }
            container.register { LogoutServiceItem(client: $0) as LogoutService }
            container.register { LogoutMenuViewControllerFactory(config: $0) }
            container.register { LogoutViewControllerFactory(config: $0, logoutService: $1, sessionService: $2) }
            container.register { LogoutPresentable(logoutFactory: $0) }
            container.register(.singleton) { UIApplication.shared as! D3UIApplication }
            container.register(.eagerSingleton) { LogoutHandler(session: $0, presenter: $1) }
            container.register(.eagerSingleton) { WatchConnectivity(userDefaults: $0) }

            container.register {
                SecurityQuestionsServiceItem(client: $0) as SecurityQuestionsService
            }

            container.register {
                SecurityQuestionsViewControllerFactory(
                    l10nProvider: try! container.resolve(),
                    componentStyleProvider: try! container.resolve(),
                    serviceItem: try! container.resolve(),
                    companyAttributesHolder: try! container.resolve()
                ) as SecurityQuestionsViewControllerFactory
            }

            container.register {
                EmailVerificationServiceItem(client: $0) as EmailVerificationService
            }
            
            container.register {
                EmailVerificationViewControllerFactory(
                    l10nProvider: try! container.resolve(),
                    componentStyleProvider: try! container.resolve(),
                    serviceItem: try! container.resolve(),
                    session: try! container.resolve()
                ) as EmailVerificationViewControllerFactory
            }
            
            container.register {
                EDocsConfigurationFactory(
                    legalService: $0,
                    disclosureViewControllerFactory: $1,
                    l10nProvider: $2,
                    companyAttributes: $3
                )
            }

            container.register { UIScreen.main }
            container.register(.eagerSingleton) { SessionObserver(analyticsTracker: $0, userSession: $1) }
            container.register(.singleton) { ChallengeNetworkInterceptorItem() }
            container.register(.singleton) { AuthUserStore(userDefaults: $0) }
            
            container.register(.singleton) { QRCodeUtils() }
            container.register { QRScannerViewControllerFactory(utils: $0, l10nProvider: $1) }
            
            AuthenticationModule.provideDependencies(to: container)
            BuildInfoScreenModule.provideDependencies(to: container)
            WebModule.provideDependencies(to: container)
            SessionExpirationModule.provideDependencies(to: container)
            BiometricsModule.provideDependencies(to: container)
            ComponentKitModule.provideDependencies(to: container)
            RDCModule.provideDependencies(to: container)
            AccountsPresentationModule.provideDependencies(to: container)
            FeatureTourModule.provideDependencies(to: container)
            InAppRatingModule.provideDependencies(to: container)
            ThreatMetrixChallengeNetworkInterceptorModule.provideDependencies(to: container)
            ProfileIconManagerModule.provideDependencies(to: container)
            AkamaiChallengeNetworkInterceptorModule.provideDependencies(to: container)
            DeviceDescriptionChallengeNetworkInterceptorModule.provideDependencies(to: container)
            DeviceDescriptionEnablementNetworkInterceptorModule.provideDependencies(to: container)
            RequestTransformerModule.provideDependencies(to: container)
            ContactsModule.provideDependencies(to: container)
            CardControlModule.provideDependencies(to: container)
        }

        DependencyContainer.uiContainers = [dependencyContainer]
        DependencyContainer.nibInjectableContainers = [dependencyContainer]
    }
}
