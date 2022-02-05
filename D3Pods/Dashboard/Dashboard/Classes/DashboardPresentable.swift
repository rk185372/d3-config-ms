//
//  DashboardPresentable.swift
//  Dashboard
//
//  Created by Andrew Watt on 7/11/18.
//

import Foundation
import Utilities
import Navigation

public final class DashboardPresentable: RootPresentable {
    private let factory: DashboardViewControllerFactory
    
    public init(factory: DashboardViewControllerFactory) {
        self.factory = factory
    }

    public func createViewController(presentingFrom presenter: RootPresenter) -> UIViewController {
        fatalError(
            "This method is a no-op for the DashboardPresentable use createViewController(presentingFrom:withTabBarControllers:)"
        )
    }

    public func createViewController(
        presentingFrom presenter: RootPresenter,
        withTabBarViewControllers controllers: [UIViewController] = []) -> UIViewController {
        return factory.create(withTabBarViewControllers: controllers)
    }
}
