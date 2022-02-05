//
//  EnableTouchIDConfiguration.swift
//  Enablement
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Localization
import Network
import LegalContent
import RxSwift
import Utilities

struct EnableTouchIDConfiguration: EnableFeatureConfiguration {
    let image: UIImage
    let helperText: String
    let disclosureButtonTitle: String
    let disableButtonTitle: String
    let enableButtonTitle: String
    let enableErrorAlertTitle: String
    let enableErrorAlertMessage: String
    let completionHandler: () -> Void
    
    private let services: EnablementConfigurationServices
    
    init(l10nProvider: L10nProvider,
         enablementConfigurationServices: EnablementConfigurationServices,
         userDefaults: UserDefaults) {
        image = UIImage(named: "TouchID", in: EnablementBundle.bundle, compatibleWith: nil)!
        helperText = l10nProvider.localize("device.config-fingerprint.title")
        disclosureButtonTitle = l10nProvider.localize("device.config-fingerprint.disclosure")
        disableButtonTitle = l10nProvider.localize("device.config-fingerprint.decline")
        enableButtonTitle = l10nProvider.localize("device.config-fingerprint.confirm")
        enableErrorAlertTitle = l10nProvider.localize("device.config-fingerprint.errorTitle")
        enableErrorAlertMessage = l10nProvider.localize("device.config-biometrics.errorText")
        self.services = enablementConfigurationServices
        self.completionHandler = {
            userDefaults.set(value: true, key: KeyStore.performedBiometricsSetup)
        }
    }
    
    func enable() -> Completable {
        return services.enableBiometrics()
    }
    
    func retrieveDisclosureText() -> Single<String> {
        return services.retrieveDisclosureText(legalServiceType: .biometricAuthentication)
    }
}
