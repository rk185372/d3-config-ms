//
//  InAppRatingModule.swift
//  InAppRating
//
//  Created by Jose Torres on 7/22/20.
//

import Foundation
import InAppRatingApi
import DependencyContainerExtension

public final class InAppRatingModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register(.singleton) { MedalliaInAppRatingManager(companyAttributesHolder: $0) as InAppRatingManager }
        container.register { FeedbackViewControllerFactory(companyAttributesHolder: $0) }
    }
}
