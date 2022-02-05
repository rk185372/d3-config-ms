//
//  AddOfflineAccountViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/15/19.
//

import D3Accounts
import ComponentKit
import Localization
import Foundation
import Utilities

final class AddOfflineAccountViewControllerFactory: ViewControllerFactory {
    private let serviceItem: AccountsService
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider

    init(serviceItem: AccountsService, l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        self.serviceItem = serviceItem
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }

    func create() -> UIViewController {
        return AddOfflineAccountViewController(
            serviceItem: serviceItem,
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }
}
