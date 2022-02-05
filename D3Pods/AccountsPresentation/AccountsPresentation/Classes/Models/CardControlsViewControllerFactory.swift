//
//  CardControlsViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import Foundation
import D3Accounts
import Localization
import ComponentKit

public final class CardControlsViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let buttonPresenterFactory: ButtonPresenterFactory
    private let serviceItem: AccountsService
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         buttonPresenterFactory: ButtonPresenterFactory,
         serviceItem: AccountsService) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.buttonPresenterFactory = buttonPresenterFactory
        self.serviceItem = serviceItem
    }
    
    func create(account: Account) -> CardControlsViewController {
        return CardControlsViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            account: account, serviceItem: serviceItem,
            buttonPresenterFactory: buttonPresenterFactory
        )
    }
}
