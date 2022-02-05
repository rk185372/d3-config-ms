//
//  AccountPresenterFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 11/13/17.
//

import Foundation
import D3Accounts
import UITableViewPresentation

protocol AccountPresenterFactory {
    func create(account: AccountListItem) -> AnyUITableViewPresentable
}
