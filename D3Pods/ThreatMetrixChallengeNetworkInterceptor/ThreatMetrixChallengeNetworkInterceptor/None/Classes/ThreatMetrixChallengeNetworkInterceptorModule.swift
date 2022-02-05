//
//  ThreatMetrixChallengeNetworkInterceptorModule.swift
//  AuthChallengeNetworkInterceptor
//
//  Created by Chris Carranza on 5/6/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import DependencyContainerExtension

public final class ThreatMetrixChallengeNetworkInterceptorModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        (try! container.resolve() as ChallengeNetworkInterceptorItem).register(interceptor: NoneThreatMetrixChallengeNetworkInterceptor())
    }
}
