//
//  InAppRatingModule.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/10/19.
//

import Foundation
import DependencyContainerExtension
import InAppRatingApi

public final class InAppRatingModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register(.singleton) { InAppRatingManagerItem() as InAppRatingManager }
    }
}
