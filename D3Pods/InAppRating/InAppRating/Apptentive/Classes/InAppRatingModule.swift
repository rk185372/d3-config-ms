//
//  InAppRatingModule.swift
//  InAppRating
//
//  Created by Branden Smith on 8/26/19.
//

import Foundation
import InAppRatingApi
import DependencyContainerExtension

public final class InAppRatingModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register {
            ApptentiveInAppRatingManager(companyAttributesHolder: $0) as InAppRatingManager
        }
    }
}
