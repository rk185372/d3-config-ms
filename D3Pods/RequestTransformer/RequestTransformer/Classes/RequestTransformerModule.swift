//
//  RequestTransformerModule.swift
//  Pods
//
//  Created by Branden Smith on 11/15/19.
//

import Dip
import DependencyContainerExtension
import Foundation
import Utilities

public final class RequestTransformerModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register(.singleton) {
            NetworkRequestTransformer() as RequestTransformer
        }
    }
}
