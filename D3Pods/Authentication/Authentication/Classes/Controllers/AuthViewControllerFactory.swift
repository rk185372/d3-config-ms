//
//  AuthViewControllerFactory.swift
//  Authentication
//
//  Created by Andrew Watt on 8/15/18.
//

import AppConfiguration
import CompanyAttributes
import Foundation
import InAppRatingApi
import Localization
import ComponentKit
import Dashboard
import Navigation
import Biometrics
import Utilities
import UserInteraction
import Analytics

public final class AuthViewControllerFactory {
    private let componentConfig: ComponentConfig
    private let challengeServiceFactory: ChallengeServiceFactory
    private let mfaEnrollmentServiceFactory: MFAEnrollmentServiceFactory
    private let authUserStore: AuthUserStore
    private let persistenceHelper: ChallengePersistenceHelper
    private let biometricsHelper: BiometricsHelper
    private let biometricsAutoPromptManagerFactory: BiometricsAutoPromptManagerFactory
    private let companyAttributes: CompanyAttributesHolder
    private let bundle: Bundle
    private let userInteraction: UserInteraction
    private let analyticsTracker: AnalyticsTracker
    private let restServer: RestServer
    private let uuid: D3UUID
    private let inAppRatingManager: InAppRatingManager
    
    init(componentConfig: ComponentConfig,
         challengeServiceFactory: ChallengeServiceFactory,
         mfaEnrollmentServiceFactory: MFAEnrollmentServiceFactory,
         authUserStore: AuthUserStore,
         persistenceHelper: ChallengePersistenceHelper,
         biometricsHelper: BiometricsHelper,
         biometricsAutoPromptManagerFactory: BiometricsAutoPromptManagerFactory,
         companyAttributes: CompanyAttributesHolder,
         bundle: Bundle,
         userInteraction: UserInteraction,
         analyticsTracker: AnalyticsTracker,
         restServer: RestServer,
         uuid: D3UUID,
         inAppRatingManager: InAppRatingManager) {
        self.componentConfig = componentConfig
        self.challengeServiceFactory = challengeServiceFactory
        self.mfaEnrollmentServiceFactory = mfaEnrollmentServiceFactory
        self.authUserStore = authUserStore
        self.persistenceHelper = persistenceHelper
        self.biometricsHelper = biometricsHelper
        self.biometricsAutoPromptManagerFactory = biometricsAutoPromptManagerFactory
        self.companyAttributes = companyAttributes
        self.bundle = bundle
        self.userInteraction = userInteraction
        self.analyticsTracker = analyticsTracker
        self.restServer = restServer
        self.uuid = uuid
        self.inAppRatingManager = inAppRatingManager
    }
    
    public func createPrimaryViewController(withPresenter presenter: AuthPresenter, suppressAutoPrompt: Bool) -> AuthPrimaryViewController {
        let viewModel = AuthPrimaryViewModel(snapshotToken: authUserStore.snapshotToken)
        return AuthPrimaryViewController(
            componentConfig: componentConfig,
            viewModel: viewModel,
            presenter: presenter,
            challengeService: challengeServiceFactory.create(),
            mfaEnrollmentService: mfaEnrollmentServiceFactory.create(),
            persistenceHelper: persistenceHelper,
            biometricsHelper: biometricsHelper,
            biometricsAutoPromptManager: biometricsAutoPromptManagerFactory.create(suppressPrompt: suppressAutoPrompt),
            companyAttributes: companyAttributes,
            bundle: bundle,
            userInteraction: userInteraction,
            analyticsTracker: analyticsTracker,
            restServer: restServer,
            uuid: uuid,
            inAppRatingManager: inAppRatingManager
        )
    }
    
    public func createSecondaryViewController(
        withPresenter presenter: AuthPresenter,
        challenge: ChallengeResponse,
        mfaEnrollmentResponse: MFAEnrollmentResponse?,
        shouldSaveUsernameEnabled: Bool?,
        username: String?) -> AuthSecondaryViewController {
        return AuthSecondaryViewController(
            l10nProvider: componentConfig.l10nProvider,
            componentStyleProvider: componentConfig.componentStyleProvider,
            challenge: challenge,
            mfaEnrollmentResponse: mfaEnrollmentResponse,
            challengeService: challengeServiceFactory.create(),
            presenter: presenter,
            inAppRatingManager: inAppRatingManager,
            biometricsHelper: biometricsHelper,
            companyAttributes: companyAttributes,
            persistenceHelper: persistenceHelper,
            shouldSaveUsernameEnabled: shouldSaveUsernameEnabled,
            username: username
        )
    }
}
