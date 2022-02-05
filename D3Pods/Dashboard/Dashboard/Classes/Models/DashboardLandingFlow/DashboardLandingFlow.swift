//
//  DashboardLandingFlow.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 15/10/2021.
//

import Foundation

public protocol DashboardLandingStepDelegate: AnyObject {
    func stepCompleted()
}

public protocol DashboardLandingStep {
    func execute(on controller: UIViewController, withDelegate delegate: DashboardLandingStepDelegate)
}

public protocol DashboardLandingFlow {
    func start(on controller: UIViewController)
}

public final class DashboardLandingFlowItem: DashboardLandingFlow, DashboardLandingStepDelegate {
    private var steps: [DashboardLandingStep]
    private weak var controller: UIViewController?
    
    public init(steps: [DashboardLandingStep]) {
        self.steps = steps
    }
    
    public func start(on controller: UIViewController) {
        self.controller = controller
        steps.first?.execute(on: controller, withDelegate: self)
    }
    
    public func stepCompleted() {
        steps.removeFirst()
        if let next = steps.first, let controller = self.controller {
            next.execute(on: controller, withDelegate: self)
        }
    }
}
