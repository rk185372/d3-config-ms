//
//  TransactionRow.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/17/18.
//

import Localization
import Snapshot
import UIKit
import UITableViewPresentation
import Utilities

class TransactionRow: UITableViewPresentable {
    let wrappedTransaction: Snapshot.WrappedTransaction
    let l10nProvider: L10nProvider

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    var dateFormatter: DateFormatter {
        return DateFormatter.abbreviatedMonthOverDay
    }

    init(transaction wrappedTransaction: Snapshot.WrappedTransaction, l10nProvider: L10nProvider) {
        self.wrappedTransaction = wrappedTransaction
        self.l10nProvider = l10nProvider
    }
    
    func configure(cell: TransactionCell, at indexPath: IndexPath) {
        cell.dateLabel.text = wrappedTransaction.transaction.postDate.map(dateFormatter.string(from:))?.uppercased()
        cell.descriptionLabel.text = wrappedTransaction.transaction.description

        let currencyFormatter = NumberFormatter.currencyFormatter(currencyCode: wrappedTransaction.currencyCode)
        cell.amountLabel.text = currencyFormatter.string(from: wrappedTransaction.transaction.amount)
        cell.accountLabel.text = wrappedTransaction.accountName
        cell.statusLabel.isHidden = !wrappedTransaction.transaction.pending
        cell.statusLabel.text = l10nProvider.localize("transaction.status.pending")
    }
}

extension TransactionRow: Equatable {
    public static func ==(lhs: TransactionRow, rhs: TransactionRow) -> Bool {
        return lhs.wrappedTransaction.transaction == rhs.wrappedTransaction.transaction
    }
}

extension TransactionRow: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: Bundle.main)
    }
}
