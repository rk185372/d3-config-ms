//
//  AkamaiChallengeNetworkInterceptorModule.swift
//  Akamai
//
//  Created by Branden Smith on 8/13/19.
//

import AuthChallengeNetworkInterceptorApi
import Foundation
import DependencyContainerExtension

public final class AkamaiChallengeNetworkInterceptorModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        (try! container.resolve() as ChallengeNetworkInterceptorItem).register(interceptor: AkamaiChallengeNetworkInterceptor())
    }
}
