//
//  BiometricsModule.swift
//  Biometrics
//
//  Created by Chris Carranza on 12/17/18.
//

import Foundation
import Dip
import DependencyContainerExtension
import LocalAuthentication
import BiometricKeychainAccess

public final class BiometricsModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { LAContext() as LocalAuthContext }
        container.register { BiometricKeychainAccess(localAuthContext: $0, userDefaults: $1) }
        container.register { BiometricsAutoPromptManagerFactory(biometricsHelper: $0) }
        container.register { BiometricsService(client: $0, uuid: $1, networkInterceptor: $2) }
        container.register(.singleton) {
            BiometricsHelperItem(
                companyAttributes: try container.resolve(),
                keychainAccess: try container.resolve(),
                deviceInfoService: try container.resolve(),
                biometricsService: try container.resolve(),
                application: try container.resolve(),
                userDefaults: try container.resolve(),
                userStore: try container.resolve()
            ) as BiometricsHelper
        }
    }
}
