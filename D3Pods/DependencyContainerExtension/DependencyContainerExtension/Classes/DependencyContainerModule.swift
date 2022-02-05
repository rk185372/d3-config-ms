//
//  DependencyContainerModule.swift
//  DependencyContainerExtension
//
//  Created by Chris Carranza on 12/14/18.
//

import Foundation
import Dip

public typealias DependencyContainer = Dip.DependencyContainer

public protocol DependencyContainerModule {
    static func provideDependencies(to container: DependencyContainer)
}
