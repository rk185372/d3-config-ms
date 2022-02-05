//
//  EnableFeatureConfigurationFactory.swift
//  Enablement
//
//  Created by Chris Carranza on 6/6/18.
//

import Foundation
import Localization
import ComponentKit
import LegalContent
import Biometrics
import Utilities

public final class EnableFeatureConfigurationFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let enablementConfigurationServices: EnablementConfigurationServices
    private let userDefaults: UserDefaults
    private let userStore: AuthUserStore
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                enablementConfigurationServices: EnablementConfigurationServices,
                userDefaults: UserDefaults,
                userStore: AuthUserStore) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.enablementConfigurationServices = enablementConfigurationServices
        self.userDefaults = userDefaults
        self.userStore = userStore
    }
    
    public func createFaceIDConfiguration() -> EnableFeatureConfiguration {
        return EnableFaceIDConfiguration(
            l10nProvider: l10nProvider,
            enablementConfigurationServices: enablementConfigurationServices,
            userDefaults: userDefaults
        )
    }
    
    public func createTouchIDConfiguration() -> EnableFeatureConfiguration {
        return EnableTouchIDConfiguration(
            l10nProvider: l10nProvider,
            enablementConfigurationServices: enablementConfigurationServices,
            userDefaults: userDefaults
        )
    }
    
    public func createSnapshotConfiguration() -> EnableFeatureConfiguration {
        return EnableSnapshotConfiguration(
            l10nProvider: l10nProvider,
            enablementConfigurationServices: enablementConfigurationServices,
            userStore: userStore
        )
    }
}
