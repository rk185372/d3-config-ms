//
//  LocationsNavigationController.swift
//  Locations
//
//  Created by Chris Carranza on 11/21/17.
//

import Dip
import Locations
import Network
import UIKit

final class LocationsNavigationController: UINavigationController {
    /// The depenency container for locations
    let dependencyContainer = DependencyContainer { container in
        container.register { LocationsServiceItem(client: $0) as LocationsService }
        container.register {
            LocationsViewControllerFactory(
                locationsService: try container.resolve(),
                styleProvider: try container.resolve(),
                l10nProvider: try container.resolve(),
                companyAttributes: try container.resolve()
            )
        }
        container
            .register(tag: "LocationDetailsViewController") { LocationDetailsViewController() }
            .resolvingProperties { container, controller in
                controller.analyticsTracker = try container.resolve()
            }
    }
}
