//
//  RDCDepositAccountPresenterFactory.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/14/18.
//

import D3Accounts
import Foundation
import Localization
import UITableViewPresentation

final class RDCDepositAccountPresenterFactory {
    private let l10nProvider: L10nProvider

    init(l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
    }

    func create(depositAccounts: [DepositAccount]) -> [RDCDepositAccountPresenter] {
        return depositAccounts.map { return create(depositAccount: $0) }
    }
    
    func create(depositAccount: DepositAccount) -> RDCDepositAccountPresenter {
        return RDCDepositAccountPresenter(depositAccount: depositAccount, l10nProvider: l10nProvider)
    }
}
