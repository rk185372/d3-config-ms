//
//  DeviceDescriptionChallengeNetworkInterceptorModule.swift
//  DeviceDescriptionChallengeNetworkInterceptor
//
//  Created by David McRae on 8/28/19.
//

import Foundation
import EnablementNetworkInterceptorApi
import DependencyContainerExtension

public final class DeviceDescriptionEnablementNetworkInterceptorModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        (try! container.resolve() as EnablementNetworkInterceptorItem)
            .register(
                interceptor: DeviceDescriptionEnablementNetworkInterceptor(
                    companyAttributes: try! container.resolve(), 
                    device: try! container.resolve()
                )
            )
    }
}
