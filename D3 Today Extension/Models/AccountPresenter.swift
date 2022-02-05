//
//  AccountPresenter.swift
//  D3 Banking
//
//  Created by David McRae on 4/25/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Accounts
import Foundation
import Snapshot
import UITableViewPresentation
import Utilities

public class AccountPresenter: UITableViewPresentable {
    let account: Snapshot.Account

    public var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    
    public init(account: Snapshot.Account) {
        self.account = account
    }
    
    public func configure(cell: AccountCell, at indexPath: IndexPath) {
        cell.nameLabel.text = account.name
        if let balance = account.balance {
            cell.balanceLabel.text = balance.formatted(currencyCode: account.currencyCode)
        } else {
            cell.balanceLabel.text = nil
        }
    }
}

extension AccountPresenter: Equatable {
    public static func ==(lhs: AccountPresenter, rhs: AccountPresenter) -> Bool {
        guard lhs.account == rhs.account else { return false }
        
        return true
    }
}

extension AccountPresenter: UITableViewNibRegistrable {}
