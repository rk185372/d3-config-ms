//
//  AccountPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/12/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UITableViewPresentation
import D3Accounts
import Utilities

class AccountPresenter: UITableViewPresentable {
    let account: AccountListItem
    let balanceTypeText: String

    var accountNumberViewColor: UIColor?

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    
    init(account: AccountListItem, balanceTypeText: String) {
        self.account = account
        self.balanceTypeText = balanceTypeText
    }
    
    func configure(cell: AccountCell, at indexPath: IndexPath) {
        cell.accountCircle.label.text = account.name.abbreviated()
        
        cell.nameLabel.text = account.displayableName
        cell.balanceLabel.text = NumberFormatter.currencyFormatter(currencyCode: account.currencyCode).string(from: account.balance)

        if let number = account.accountNumber.map({ $0.masked() }), !number.isEmpty {
            cell.accountNumberLabel.isHidden = false
            cell.accountNumberLabel.text = number
        } else {
            cell.accountNumberLabel.isHidden = true
        }

        if !balanceTypeText.isEmpty {
            cell.balanceTypeLabel.isHidden = false
            cell.balanceTypeLabel.text = balanceTypeText
        } else {
            cell.balanceTypeLabel.isHidden = true
        }
    }
}

extension AccountPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension AccountPresenter: UITableViewEditableRow {
    var isEditable: Bool { return true }
    
    func editActions() -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .normal, title: "More", handler: { (_, _) in
                
            }),
            UITableViewRowAction(style: .default, title: "Hide", handler: { (_, _) in
                
            })
        ]
    }
}

extension AccountPresenter: Equatable {
    static func ==(lhs: AccountPresenter, rhs: AccountPresenter) -> Bool {
        guard lhs.account == rhs.account else { return false }
        
        return true
    }
}
