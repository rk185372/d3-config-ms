//
//  OnDotCardControlManager.swift
//  CardControl
//
//  Created by Elvin Bearden on 2/1/21.
//

import Foundation
import CardAppMobile
import CardControlApi
import CompanyAttributes
import ComponentKit
import Dashboard
import Localization
import Logging
import RxCocoa
import RxSwift
import Utilities
import Views

//swiftlint:disable multiple_closures_with_trailing_closure
//swiftlint:disable no_space_in_method_call
public class OnDotCardControlManager: CardControlManager {
    private class CardLogger: CardAppLogger {
        func logEvent(_ event: String) {
            DispatchQueue.background.async {
                log.debug(event)
            }
        }
    }

    public var errorRelay: BehaviorRelay<CardControlError?> = BehaviorRelay(value: nil)

    private let configuration: CardControlConfiguration
    private let branding: CardControlBranding
    private let device: Device
    private let tokenHandler: PushNotificationTokenHandler?
    private let service: OnDotService
    private let l10nProvider: L10nProvider

    private let logger = CardLogger()
    private var serviceDisposable: Disposable?
    private var bag = DisposeBag()
    private lazy var loadingView = {
        return LoadingView(
            activityIndicatorColor: .white,
            backgroundColor: UIColor.black.withAlphaComponent(0.4)
        )
    }()

    init(configuration: CardControlConfiguration,
         branding: CardControlBranding,
         device: Device,
         tokenHandler: PushNotificationTokenHandler?,
         service: OnDotService,
         l10nProvider: L10nProvider) {
        self.configuration = configuration
        self.branding = branding
        self.device = device
        self.tokenHandler = tokenHandler
        self.service = service
        self.l10nProvider = l10nProvider

        #if DEBUG
        CardAppSDK.isDebugModeEnabled = false
        #endif

        CardAppSDK.logger = logger
    }

    public func setup() -> Observable<Void> {
        return Observable.create { observer in
            _ = CardAppSDK.initialize(
                withConfiguration: self.createAppConfiguration(),
                launchDelegate: self,
                sessionDelegate: self) { (success, error) in
                guard error == nil, success else {
                    observer.onError(CardControlError.initialize(error!.description))
                    return
                }

                observer.onNext(())
            }

            return Disposables.create()
        }
    }

    public func applicationLaunched(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        CardAppSDK.shared?.applicationLaunched(withLaunchOptions: options)
    }

    public func launchCardControls(loadingPresenter: UIViewController?) {
        guard CardAppSDK.isInitialized else {
            let message = l10nProvider.localize("cardmanagement.ondot.error-message")
            errorRelay.accept(CardControlError.initialize(message))
            return
        }
        
        if let presenter = loadingPresenter {
            showLoadingView(presenter: presenter)
        }

        serviceDisposable = service
            .createSession()
            .subscribe { (configuration) in
                CardAppSDK.shared?.launch(withUserConfiguration: configuration)
            } onError: { [weak self](error) in
                guard let self = self else { return }
                log.error(error)
                let message = self.l10nProvider.localize("cardmanagement.ondot.error-message")
                let sessionError = CardControlError.initialize(message)
                self.errorRelay.accept(sessionError)
                self.hideLoadingView()
            }
    }
}

private extension OnDotCardControlManager {
    func createAppConfiguration() -> CardAppConfiguration {
        let deploymentConfiguration = CardAppDeploymentConfiguration(
            appToken: configuration.appToken,
            fiToken: configuration.fiToken,
            googleAPIKey: configuration.googleApiKey,
            deploymentToken: configuration.deploymentToken
        )

        let serverConfiguration = CardAppServerConfiguration(
            endPoint: configuration.endpoint,
            publicKeys: [] //configuration.publicKeys
        )

        let deviceConfiguration = CardAppDeviceConfiguration(
            deviceUniqueId: device.uuid,
            pushNotificationToken: tokenHandler?.pushId
        )

        let brandingConfiguration = CardAppBrandingConfiguration()
        brandingConfiguration.primaryButtonTextColor = "#FFFFFF"
        brandingConfiguration.primaryButtonBackground = branding.primaryColor.hexString(false)
        brandingConfiguration.hyperlinksTextColor = branding.primaryColor.hexString(false)
        brandingConfiguration.seperatorLineBackgroundColor = "#C7C7CC"
        brandingConfiguration.textEntryLineBackgroundColor = branding.primaryColor.hexString(false)
        brandingConfiguration.titleTextColor = "#FFFFFF"
        brandingConfiguration.titleBackgroundColor = branding.primaryColor.hexString(false)
        brandingConfiguration.secondaryAnchorHeaderTextColor = "#000000"
        brandingConfiguration.secondaryAnchorHeaderBackgroundColor = "#F7F7F7"
        brandingConfiguration.appThemeColor = branding.secondaryColor.hexString(false)
        brandingConfiguration.pagetitleTextColor = branding.primaryColor.hexString(false)

        return CardAppConfiguration(
            deploymentConfiguration: deploymentConfiguration,
            serverConfiguration: serverConfiguration,
            deviceConfiguration: deviceConfiguration,
            brandingConfiguration: brandingConfiguration,
            adaBrandingConfiguration: brandingConfiguration,
            isMultiUserModeEnabled: false
        )
    }

    private func showLoadingView(presenter: UIViewController) {
        CardAppSDK.shared?.showingTransitionLoader(true)
        presenter.view.addSubview(loadingView)
        presenter.view.bringSubviewToFront(loadingView)
        loadingView.spinner.isHidden = false
        loadingView.spinner.startAnimating()
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    private func hideLoadingView() {
        CardAppSDK.shared?.showingTransitionLoader(false)
        loadingView.removeFromSuperview()
    }
}

extension OnDotCardControlManager: CardAppLaunchDelegate {
    public func cardAppLaunched() {
        hideLoadingView()
        serviceDisposable?.dispose()
        errorRelay.accept(nil)
    }

    public func cardAppLaunchFailed(withError error: CardAppError?) {
        hideLoadingView()
        if let error = error {
            let message = l10nProvider.localize("cardmanagement.ondot.error-message")
            errorRelay.accept(CardControlError.launch(message))
            log.error("Card app launch failed: \(error.message)")
        } else {
            log.error("Card app launch failed with no error")
        }
    }

    public func exitedFromCardApp() {
        hideLoadingView()
        errorRelay.accept(nil)
    }
}

extension OnDotCardControlManager: CardAppSessionDelegate {
    public func onSessionTimeout() {
        log.debug("Session timeout")
    }

    public func updateHostAppSessionTime() {
        log.debug("Update session time")
    }

    public func renewSession(completion: @escaping ((CardAppUserConfiguration?) -> Void)) {
        if let dashboard = UIApplication.shared.windows.first?
            .rootViewController?.children.first as? DashboardViewController {
            dashboard.showLoadingView()
        }

        service.renewSession().subscribe { [weak self](configuration) in
            self?.hideLoadingView()
            completion(configuration)
        } onError: { [weak self](error) in
            self?.hideLoadingView()
            log.error("Failed to renew session with error: \(error)")
        }.disposed(by: bag)
    }
}

extension CardAppError {
    public override var description: String {
        return "\(type): \(message)"
    }
}

//swiftlint:enable multiple_closures_with_trailing_closure
//swiftlint:enable no_space_in_method_call
