//
//  StandardAccountPresenterFactory.swift
//  AccountsPresentation
//
//  Created by Andrew Watt on 8/31/18.
//

import Foundation
import Localization
import UITableViewPresentation
import D3Accounts

final class StandardAccountPresenterFactory: AccountPresenterFactory {
    private let l10nProvider: L10nProvider
    
    init(l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
    }
    
    func create(account: AccountListItem) -> AnyUITableViewPresentable {
        let balanceTypeText = l10nProvider.localize(account.balanceType.l10nKey)
        return AnyUITableViewPresentable(AccountPresenter(account: account, balanceTypeText: balanceTypeText))
    }
}
