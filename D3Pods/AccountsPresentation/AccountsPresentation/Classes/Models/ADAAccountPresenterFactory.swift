//
//  ADAAccountPresenterFactory.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/5/18.
//

import Foundation
import D3Accounts
import UITableViewPresentation
import Localization

final class ADAAccountPresenterFactory: AccountPresenterFactory {
    private let l10nProvider: L10nProvider
    
    init(l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
    }
    
    func create(account: AccountListItem) -> AnyUITableViewPresentable {
        let balanceTypeText = l10nProvider.localize(account.balanceType.l10nKey)
        return AnyUITableViewPresentable(ADAAccountPresenter(account: account, balanceTypeText: balanceTypeText))
    }
}
