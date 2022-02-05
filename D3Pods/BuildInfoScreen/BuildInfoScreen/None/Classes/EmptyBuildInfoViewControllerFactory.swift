//
//  EmptyBuildInfoViewControllerFactory.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 9/30/19.
//

import Foundation
import Utilities

public typealias BuildInfoViewControllerFactory = EmptyBuildInfoViewControllerFactory

public final class EmptyBuildInfoViewControllerFactory: ViewControllerFactory {
    public func create() -> UIViewController {
        fatalError("EmptyBuildInfoViewControllerFactory is a placeholder and should not be used")
    }
}
