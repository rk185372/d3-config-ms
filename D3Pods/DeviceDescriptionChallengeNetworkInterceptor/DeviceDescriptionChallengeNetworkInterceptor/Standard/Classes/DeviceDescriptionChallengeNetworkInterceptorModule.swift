//
//  DeviceDescriptionChallengeNetworkInterceptorModule.swift
//  DeviceDescriptionChallengeNetworkInterceptor
//
//  Created by David McRae on 8/28/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import DependencyContainerExtension

public final class DeviceDescriptionChallengeNetworkInterceptorModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        (try! container.resolve() as ChallengeNetworkInterceptorItem)
            .register(
                interceptor: DeviceDescriptionChallengeNetworkInterceptor(
                    companyAttributes: try! container.resolve(), 
                    device: try! container.resolve()
                )
            )
    }
}
