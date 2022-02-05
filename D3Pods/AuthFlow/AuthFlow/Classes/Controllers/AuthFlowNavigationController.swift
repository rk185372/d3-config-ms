//
//  AuthFlowNavigationController.swift
//  AuthFlow
//
//  Created by Chris Carranza on 6/8/18.
//

import AppInitialization
import Authentication
import Biometrics
import ComponentKit
import Foundation
import Localization
import Logging
import Navigation
import Network
import PostAuthFlow
import RxCocoa
import RxSwift
import Session
import Utilities

public final class AuthFlowNavigationController: UINavigationControllerComponent {
    fileprivate let authViewControllerFactory: AuthViewControllerFactory
    fileprivate let sessionService: SessionService
    fileprivate let appInitializationService: AppInitializationService
    fileprivate let startupHolder: StartupHolder
    fileprivate let postAuthFlowFactory: PostAuthFlowFactory
    fileprivate let biometricsHelper: BiometricsHelper
    fileprivate let l10nProvider: L10nProvider
    fileprivate let presenter: AuthPresenter

    fileprivate let _authenticated = BehaviorRelay(value: false)

    private let bag = DisposeBag()

    private var biometricEnrollment: BiometricEnrollment = .none
    private var postAuthFlow: PostAuthFlow?

    public init(authViewControllerFactory: AuthViewControllerFactory,
                sessionService: SessionService,
                appInitializationService: AppInitializationService,
                startupHolder: StartupHolder,
                postAuthFlowFactory: PostAuthFlowFactory,
                presenter: AuthPresenter,
                biometricsHelper: BiometricsHelper,
                l10nProvider: L10nProvider,
                suppressAutoPrompt: Bool) {
        self.authViewControllerFactory = authViewControllerFactory
        self.sessionService = sessionService
        self.appInitializationService = appInitializationService
        self.startupHolder = startupHolder
        self.postAuthFlowFactory = postAuthFlowFactory
        self.presenter = presenter
        self.l10nProvider = l10nProvider
        self.biometricsHelper = biometricsHelper

        super.init(nibName: nil, bundle: nil)

        let primaryViewController = authViewControllerFactory
            .createPrimaryViewController(withPresenter: presenter, suppressAutoPrompt: suppressAutoPrompt)
        primaryViewController.delegate = self
        
        pushViewController(primaryViewController, animated: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var authenticated: Bool {
        get { return _authenticated.value }
        set { _authenticated.accept(newValue) }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
    }
    
    private func resetToPrimaryViewController() {
        (viewControllers.first as? AuthPrimaryViewController)?.refreshChallenge()
        _ = popToRootViewController(animated: true)
    }
    
    private func handleBiometricEnablement() {
        switch biometricEnrollment {
        case .enroll, .reEnroll:
            // We ignore a possible error in the opt out call that may happen
            // if a token doesn't get properly removed or doesn't exist. We
            // still call the opt in service just in case to ensure a better UX.
            // It's also possible for the server to have the token but the device
            // not have one if a user loads from a backup device that was enrolled,
            // so we still need to refresh that token on the server.
            _ = biometricsHelper
                .optOutBiometricAuth()
                .ignoreError()
                .andThen(biometricsHelper.optInBiometricAuth())
                .subscribe()
            
        default: break
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }
}

extension Reactive where Base == AuthFlowNavigationController {
    public var authenticated: Driver<Bool> {
        return base._authenticated.asDriver()
    }
}

extension AuthFlowNavigationController: PostAuthFlowDelegate {
    public func postAuthFlow(advancedToViewController viewController: UIViewController?) {
        if let viewController = viewController {
            pushViewController(viewController, animated: true)
        } else {
            handleBiometricEnablement()
            authenticated = true
        }
    }
    
    public func postAuthFlowCancelled() {
        NotificationCenter.default.post(name: .loggedOut, object: nil)
    }
}

extension AuthFlowNavigationController: AuthDelegate {
    public func authViewControllerAuthenticated(_ viewController: AuthViewController, completionHandler: @escaping(UserSession) -> Void) {
        sessionService
            .ensureSession()
            .flatMap { userSession in
                self.appInitializationService
                    .updateStartup()
                    .map { startup -> (Decoded<Startup, String>, UserSession) in
                        return (startup, userSession)
                    }
            }
            .subscribe(onSuccess: { [unowned self] observables in
                let updatedStartup = observables.0
                let userSession = observables.1

                self.startupHolder.decodedStartup = updatedStartup

                let termsOfService = userSession.session?.tos ?? []
                let setupSteps = userSession.session?.setupSteps ?? []
                let paperlessPromptAccounts = userSession.session?.paperlessPromptAccounts ?? []
                let estatementPromptAccounts = userSession.session?.estatementPromptAccounts ?? []
                let accountNoticePromptAccounts = userSession.session?.accountNoticePromptAccounts ?? []
                let promptForElectronicTaxDocuments = userSession.session?.promptForElectronicTaxDocuments ?? false

                // Update the user session now that we have grabbed all of the post auth steps.
                userSession.rawSession = userSession.rawSession?.copyClearingSetupSteps()

                let postAuthFlow = self.postAuthFlowFactory.create(
                    termsOfService: termsOfService,
                    setupSteps: setupSteps,
                    paperlessPromptAccounts: paperlessPromptAccounts,
                    estatementPromptAccounts: estatementPromptAccounts,
                    accountNoticePromptAccounts: accountNoticePromptAccounts,
                    promptForElectronicTaxDocuments: promptForElectronicTaxDocuments,
                    l10nProvider: self.l10nProvider,
                    delegate: self
                )
                postAuthFlow.advance()
                self.postAuthFlow = postAuthFlow
                
                completionHandler(userSession)
            }, onError: { error in
                log.error("Error fetching session: \(error)", context: error)
                if case ResponseError.systemMaintenance = error {
                    return
                }
                
                let alertController = UIAlertController(
                    title: self.l10nProvider.localize("alert.standard.title"),
                    message: self.l10nProvider.localize("app.error.generic"),
                    preferredStyle: .alert
                )
                alertController.addAction(
                    UIAlertAction(title: self.l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: { _ in
                        // We don't actually need to call logout here because this error block
                        // means that the session data (UserSession.rawSession) will have never been set.
                        self.resetToPrimaryViewController()
                    })
                )
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    public func authViewController(_ viewController: AuthViewController,
                                   receivedAdditionalChallenge challenge: ChallengeResponse,
                                   receivedAdditionalMFAEnrollResponse mfaEnrollResponse: MFAEnrollmentResponse?,
                                   shouldSaveUsernameEnabled: Bool?,
                                   username: String?
                               ) {
        let nextViewController = authViewControllerFactory.createSecondaryViewController(
            withPresenter: presenter,
            challenge: challenge,
            mfaEnrollmentResponse: mfaEnrollResponse,
            shouldSaveUsernameEnabled: shouldSaveUsernameEnabled,
            username: username)
        
        nextViewController.delegate = self
        pushViewController(nextViewController, animated: true)
    }

    public func authViewControllerCanceled(_ viewController: AuthViewController) {
        resetToPrimaryViewController()
    }

    public func authViewControllerBackActionTaken(_ viewController: AuthViewController) {
        _ = popViewController(animated: true)
    }

    public func authViewControllerNeedsBiometricEnrollment(_ enrollmentType: BiometricEnrollment) {
        biometricEnrollment = enrollmentType
    }
}
