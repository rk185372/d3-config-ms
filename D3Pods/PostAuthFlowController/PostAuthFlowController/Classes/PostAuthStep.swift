//
//  PostAuthStep.swift
//  PostAuthFlowController
//
//  Created by Andrew Watt on 8/23/18.
//

import Foundation

public protocol PostAuthStep {
    func viewControllers() -> AnyIterator<UIViewController>
}
