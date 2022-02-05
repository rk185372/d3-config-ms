//
//  FeatureTourModule.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/10/19.
//

import Foundation
import Dip
import DependencyContainerExtension

public final class FeatureTourModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { FeatureTourPresentable() }
    }
}
