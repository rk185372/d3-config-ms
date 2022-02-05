//
//  LocationsViewControllerFactory.swift
//  Locations
//
//  Created by Chris Carranza on 11/8/17.
//

import ComponentKit
import Foundation
import Localization
import Locations
import Utilities
import CompanyAttributes

final class LocationsViewControllerFactory: ViewControllerFactory {
    private let locationsService: LocationsService
    private let componentStyleProvider: ComponentStyleProvider
    private let l10nProvider: L10nProvider
    private let companyAttributes: CompanyAttributesHolder
    
    // swiftlint:disable:next line_length
    public init(locationsService: LocationsService, styleProvider: ComponentStyleProvider, l10nProvider: L10nProvider, companyAttributes: CompanyAttributesHolder) {
        self.locationsService = locationsService
        self.componentStyleProvider = styleProvider
        self.l10nProvider = l10nProvider
        self.companyAttributes = companyAttributes
    }
    
    public func create() -> UIViewController {
        let viewModel = LocationsViewModel(service: locationsService)

        let locationsViewController = StoryboardScene.Locations.locationsViewController.instantiate()
        locationsViewController.viewModel = viewModel
        locationsViewController.styleProvider = componentStyleProvider
        locationsViewController.l10nProvider = l10nProvider
        locationsViewController.companyAttributesHolder = companyAttributes

        return locationsViewController
    }
}
