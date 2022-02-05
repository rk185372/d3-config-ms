//
//  InAppRatingModule.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import DependencyContainerExtension
import InAppRatingApi

public final class InAppRatingModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { InAppRatingServiceItem(client: $0) as InAppRatingService }
        container.register(.singleton) { InAppRatingManagerItem(service: $0, l10nProvider: $1) as InAppRatingManager }
    }
}
