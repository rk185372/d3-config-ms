//
//  TransactionsViewControllerFactory.swift
//  TransactionsPresentation
//
//  Created by Chris Carranza on 11/13/17.
//

import Foundation
import D3Accounts
import Transactions
import Localization
import ComponentKit

final class TransactionsViewControllerFactory {
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let transactionsService: TransactionsService
    private let accountDetailsViewControllerFactory: AccountDetailsViewControllerFactory
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         transactionsService: TransactionsService,
         accountDetailsViewControllerFactory: AccountDetailsViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.transactionsService = transactionsService
        self.accountDetailsViewControllerFactory = accountDetailsViewControllerFactory
    }
    
    func create(account: AccountListItem) -> UIViewController {
        return TransactionsViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            account: account,
            transactionService: transactionsService,
            accountDetailsViewControllerFactory: accountDetailsViewControllerFactory
        )
    }
}
