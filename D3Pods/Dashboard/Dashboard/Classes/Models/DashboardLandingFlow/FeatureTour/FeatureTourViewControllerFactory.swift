//
//  FeatureTourViewControllerFactory.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 15/10/2021.
//

import Foundation
import Localization

public protocol FeatureTourViewControllerFactory {
    func create(delegate: FeatureTourViewControllerDelegate) -> UIViewController
}

public final class FeatureTourViewControllerFactoryItem: FeatureTourViewControllerFactory {
    private let l10nProvider: L10nProvider
    
    public init(l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
    }
    
    public func create(delegate: FeatureTourViewControllerDelegate) -> UIViewController {
        return FeatureTourViewController(l10nProvider: l10nProvider, delegate: delegate)
    }
}
