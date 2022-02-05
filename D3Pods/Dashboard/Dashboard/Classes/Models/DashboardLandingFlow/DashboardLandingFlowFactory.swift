//
//  DashboardLandingFlowFactory.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 15/10/2021.
//

import Foundation
import CompanyAttributes

public protocol DashboardLandingFlowFactory {
    func create() -> DashboardLandingFlow
}

public final class DashboardLandingFlowFactoryItem: DashboardLandingFlowFactory {
    private let factory: FeatureTourViewControllerFactory
    private let featureTourService: FeatureTourService
    private let companyAttributesHolder: CompanyAttributesHolder
    
    public init(factory: FeatureTourViewControllerFactory,
                featureTourService: FeatureTourService,
                companyAttributesHolder: CompanyAttributesHolder) {
        self.factory = factory
        self.featureTourService = featureTourService
        self.companyAttributesHolder = companyAttributesHolder
    }
    
    public func create() -> DashboardLandingFlow {
        var steps = [DashboardLandingStep]()
        
        if isFeatureTourEnabled {
            steps.append(FeatureTourLandingStep(factory: factory, featureTourService: featureTourService))
        }
        
        return DashboardLandingFlowItem(steps: steps)
    }
}

private extension DashboardLandingFlowFactoryItem {
    var companyAttributes: CompanyAttributes? {
        return companyAttributesHolder.companyAttributes.value
    }
    
    var isFeatureTourEnabled: Bool {
        return companyAttributes?.boolValue(forKey: "self-service.feature.tour.enabled") ?? false
    }
}
