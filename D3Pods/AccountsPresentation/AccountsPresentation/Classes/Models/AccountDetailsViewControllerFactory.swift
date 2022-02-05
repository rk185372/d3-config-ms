//
//  AccountDetailsViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/14/18.
//

import D3Accounts
import AppConfiguration
import Foundation
import Network
import Utilities
import Localization
import ComponentKit

final class AccountDetailsViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let serviceItem: AccountsService
    private let cardControlsViewControllerFactory: CardControlsViewControllerFactory
    private let stopPaymentViewControllerFactory: StopPaymentViewControllerFactory

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         serviceItem: AccountsService,
         cardControlsViewControllerFactory: CardControlsViewControllerFactory,
         stopPaymentViewControllerFactory: StopPaymentViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.serviceItem = serviceItem
        self.cardControlsViewControllerFactory = cardControlsViewControllerFactory
        self.stopPaymentViewControllerFactory = stopPaymentViewControllerFactory
    }

    func create(account: AccountListItem) -> UIViewController {
        return AccountDetailsViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            accountListItem: account,
            serviceItem: serviceItem,
            cardControlsViewControllerFactory: cardControlsViewControllerFactory,
            stopPaymentViewControllerFactory: stopPaymentViewControllerFactory
        )
    }
}
