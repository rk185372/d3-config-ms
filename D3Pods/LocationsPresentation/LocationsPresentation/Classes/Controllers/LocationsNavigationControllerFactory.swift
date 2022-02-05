//
//  LocationsNavigationControllerFactory.swift
//  Locations
//
//  Created by Andrew Watt on 7/24/18.
//

import Foundation
import Dip
import Utilities
import Permissions

public final class LocationsNavigationControllerFactory: ViewControllerFactory {
    private let rootContainer: DependencyContainer
    
    public init(rootContainer: DependencyContainer) {
        self.rootContainer = rootContainer
    }

    public func create() -> UIViewController {
        let navigationController = LocationsNavigationController()
        let dependencyContainer = navigationController.dependencyContainer

        rootContainer.collaborate(with: dependencyContainer)
        DependencyContainer.uiContainers.append(dependencyContainer)
        
        do {
            let viewControllerFactory = try dependencyContainer.resolve() as LocationsViewControllerFactory
            navigationController.viewControllers = [viewControllerFactory.create()]
        } catch {
            fatalError("Error resolving Locations dependency graph: \(error)")
        }

        return navigationController
    }
}

extension LocationsViewController: StoryboardInstantiatable {}
extension LocationDetailsViewController: StoryboardInstantiatable {}

extension LocationsNavigationControllerFactory: Permissioned {
    public var feature: Feature {
        return .locations
    }
}
