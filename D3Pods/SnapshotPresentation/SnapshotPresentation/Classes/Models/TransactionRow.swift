//
//  TransactionRow.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/17/18.
//

import Snapshot
import Localization
import UIKit
import UITableViewPresentation
import Utilities

class TransactionRow: UITableViewPresentable {
    private static let dateFormatter = DateFormatter(formatString: "MMM\nd")
    
    let account: Snapshot.Account
    let transaction: Snapshot.Transaction
    let l10nProvider: L10nProvider

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    required init(account: Snapshot.Account, transaction: Snapshot.Transaction, l10nProvider: L10nProvider) {
        self.account = account
        self.transaction = transaction
        self.l10nProvider = l10nProvider
    }
    
    func configure(cell: TransactionCell, at indexPath: IndexPath) {
        let currencyFormatter = NumberFormatter.currencyFormatter(currencyCode: "USD")
        
        cell.dateLabel.text = transaction.postDate.map(DateFormatter.abbreviatedMonthAndDay.string(from:))?.uppercased()
        let statusString = "transaction.status.\(transaction.pending ? "pending" : "posted")"
        cell.statusLabel.text = l10nProvider.localize(statusString)
        cell.descriptionLabel.text = transaction.description
        cell.amountLabel.text = currencyFormatter.string(from: transaction.amount)
    }
}

extension TransactionRow: Equatable {
    static func ==(_ lhs: TransactionRow, _ rhs: TransactionRow) -> Bool {
        return lhs.transaction == rhs.transaction
            && lhs.cellReuseIdentifier == rhs.cellReuseIdentifier
    }
}

extension TransactionRow: UITableViewNibRegistrable {
    var nib: UINib {
        return SnapshotPresentationBundle.nib(name: cellReuseIdentifier)
    }
}
