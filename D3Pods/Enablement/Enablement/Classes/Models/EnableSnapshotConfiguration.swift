//
//  EnableSnapshotConfiguration.swift
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
import DeviceInfoService

struct EnableSnapshotConfiguration: EnableFeatureConfiguration {
    let image: UIImage
    let helperText: String
    let disclosureButtonTitle: String
    let disableButtonTitle: String
    let enableButtonTitle: String
    let enableErrorAlertTitle: String
    let enableErrorAlertMessage: String
    var completionHandler: () -> Void
    
    private let services: EnablementConfigurationServices
    private let userStore: AuthUserStore
    
    init(l10nProvider: L10nProvider,
         enablementConfigurationServices: EnablementConfigurationServices,
         userStore: AuthUserStore) {
        image = UIImage(named: "Snapshot", in: EnablementBundle.bundle, compatibleWith: nil)!
        helperText = l10nProvider.localize("device.config-snapshot.title")
        disclosureButtonTitle = l10nProvider.localize("device.config-snapshot.disclosure")
        disableButtonTitle = l10nProvider.localize("device.config-snapshot.decline")
        enableButtonTitle = l10nProvider.localize("device.config-snapshot.confirm")
        enableErrorAlertTitle = l10nProvider.localize("device.config-snapshot.errorTitle")
        enableErrorAlertMessage = l10nProvider.localize("device.config-snapshot.errorText")
        self.services = enablementConfigurationServices
        self.userStore = userStore
        self.completionHandler = { userStore.setHasPerformedSnapshotSetup() }
    }
    
    func enable() -> Completable {
        return services.enableSnapshot().do(onSuccess: { enableSnapshotResponse in
            self.userStore.setSnapshotToken(enableSnapshotResponse.token)
            NotificationCenter.default.post(name: .snapshotTokenUpdatedNotification, object: nil)
        }).asCompletable()
    }
    
    func retrieveDisclosureText() -> Single<String> {
        return services.retrieveDisclosureText(legalServiceType: .mobileSnapshot)
    }
}
