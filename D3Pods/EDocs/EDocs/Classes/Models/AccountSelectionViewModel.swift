//
//  AccountSelectionViewModel.swift
//  EDocs
//
//  Created by Andrew Watt on 8/24/18.
//

import CompanyAttributes
import Foundation
import Localization
import RxRelay
import RxSwift

final class AccountSelectionViewModel {
    let accounts: [EDocsPromptAccount]
    let presenters: [EDocsPromptAccountPresenter]
    
    init(accounts: [EDocsPromptAccount], l10nProvider: L10nProvider) {
        self.accounts = accounts
        self.presenters = accounts.map { EDocsPromptAccountPresenter(account: $0, l10nProvider: l10nProvider) }
    }
}
