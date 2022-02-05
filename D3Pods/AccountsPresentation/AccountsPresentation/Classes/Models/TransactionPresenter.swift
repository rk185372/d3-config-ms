//
//  TransactionPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 3/23/17.
//
//

import Foundation
import UITableViewPresentation
import Transactions

struct TransactionPresenter: UITableViewPresentable {
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    func configure(cell: TransactionCell, at indexPath: IndexPath) {
        cell.descriptionLabel.text = transaction.name
        cell.amountLabel.text = NumberFormatter
            .currencyFormatter(currencyCode: transaction.currencyCode)
            .string(from: transaction.amount)

        // TODO: Waiting on a decision from design about whether or
        // not we want to make l10n for these statuses or just show the
        // raw value provided by the server.
        cell.categoryLabel.text = transaction.status.rawValue

        if let balance = transaction.balance {
            cell.balanceLabel.text = NumberFormatter
                .currencyFormatter(currencyCode: transaction.currencyCode)
                .string(from: balance)
        } else {
            cell.balanceLabel.text = ""
        }
    }
}

extension TransactionPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension TransactionPresenter: Equatable {
    static func ==(lhs: TransactionPresenter, rhs: TransactionPresenter) -> Bool {
        guard lhs.transaction == rhs.transaction else { return false }
        
        return true
    }
}
