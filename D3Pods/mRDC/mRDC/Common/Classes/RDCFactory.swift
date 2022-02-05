//
//  RDCFactory.swift
//  Pods
//
//  Created by Branden Smith on 11/2/18.
//

import ComponentKit
import Dip
import Foundation
import Localization
import Utilities

public protocol RDCFactory: ViewControllerFactory {
    init(dependencyContainer: DependencyContainer)
}
