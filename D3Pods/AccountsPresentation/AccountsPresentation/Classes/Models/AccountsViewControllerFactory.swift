//
//  AccountsViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 11/13/17.
//

import D3Accounts
import Analytics
import CompanyAttributes
import ComponentKit
import Foundation
import InAppRatingApi
import Localization
import Messages
import Session
import Utilities
import Web

public final class AccountsVCFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let accountsService: AccountsService
    private let transactionsViewControllerFactory: TransactionsViewControllerFactory
    private let buttonPresenterFactory: ButtonPresenterFactory
    private let userSession: UserSession
    private let companyAttributes: CompanyAttributesHolder
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let addOfflineAccountViewControllerFactory: AddOfflineAccountViewControllerFactory
    private let profileIconCoordinatorFactory: ProfileIconCoordinatorFactory

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         accountsService: AccountsService,
         transactionsViewControllerFactory: TransactionsViewControllerFactory,
         buttonPresenterFactory: ButtonPresenterFactory,
         userSession: UserSession,
         companyAttributes: CompanyAttributesHolder,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory,
         addOfflineAccountViewControllerFactory: AddOfflineAccountViewControllerFactory,
         profileIconCoordinatorFactory: ProfileIconCoordinatorFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.accountsService = accountsService
        self.transactionsViewControllerFactory = transactionsViewControllerFactory
        self.buttonPresenterFactory = buttonPresenterFactory
        self.userSession = userSession
        self.companyAttributes = companyAttributes
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.addOfflineAccountViewControllerFactory = addOfflineAccountViewControllerFactory
        self.profileIconCoordinatorFactory = profileIconCoordinatorFactory
    }
    
    func create() -> UIViewController {
        return AccountsViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            accountsService: accountsService,
            transactionsViewControllerFactory: transactionsViewControllerFactory,
            buttonPresenterFactory: buttonPresenterFactory,
            userSession: userSession,
            companyAttributes: companyAttributes,
            externalWebViewControllerFactory: externalWebViewControllerFactory,
            addOfflineAccountViewControllerFactory: addOfflineAccountViewControllerFactory,
            profileIconCoordinatorFactory: profileIconCoordinatorFactory
        )
    }
}
