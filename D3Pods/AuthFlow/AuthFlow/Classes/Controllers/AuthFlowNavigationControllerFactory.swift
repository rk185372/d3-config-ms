//
//  AuthNavigator.swift
//  Authentication
//
//  Created by Andrew Watt on 7/9/18.
//

import AppInitialization
import UIKit
import Authentication
import CompanyAttributes
import Session
import Localization
import PostAuthFlow
import Utilities
import Biometrics

public final class AuthFlowNavigationControllerFactory {
    private let authViewControllerFactory: AuthViewControllerFactory
    private let sessionService: SessionService
    private let appInitializationService: AppInitializationService
    private let startupHolder: StartupHolder
    private let postAuthFlowFactory: PostAuthFlowFactory
    private let biometricsHelper: BiometricsHelper
    private let l10nProvider: L10nProvider
    
    private let presenter: AuthPresenter
    
    public init(authViewControllerFactory: AuthViewControllerFactory,
                sessionService: SessionService,
                appInitializationService: AppInitializationService,
                startupHolder: StartupHolder,
                postAuthFlowFactory: PostAuthFlowFactory,
                presenter: AuthPresenter,
                biometricsHelper: BiometricsHelper,
                l10nProvider: L10nProvider) {
        self.authViewControllerFactory = authViewControllerFactory
        self.sessionService = sessionService
        self.appInitializationService = appInitializationService
        self.startupHolder = startupHolder
        self.postAuthFlowFactory = postAuthFlowFactory
        self.presenter = presenter
        self.biometricsHelper = biometricsHelper
        self.l10nProvider = l10nProvider
    }
    
    public func create(suppressAutoPrompt: Bool) -> AuthFlowNavigationController {
        return AuthFlowNavigationController(
            authViewControllerFactory: authViewControllerFactory,
            sessionService: sessionService,
            appInitializationService: appInitializationService,
            startupHolder: startupHolder,
            postAuthFlowFactory: postAuthFlowFactory,
            presenter: presenter,
            biometricsHelper: biometricsHelper,
            l10nProvider: l10nProvider,
            suppressAutoPrompt: suppressAutoPrompt
        )
    }
}
