//
//  StopPaymentHistoryItemPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/19/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation
import Utilities

struct StopPaymentHistoryItemPresenter: UITableViewPresentable, Equatable {
    private let historyItem: StoppedPaymentHistoryItem

    init(historyItem: StoppedPaymentHistoryItem) {
        self.historyItem = historyItem
    }

    func configure(cell: StopPaymentHistoryCell, at indexPath: IndexPath) {
        cell.expirationDateLabel.text = historyItem.expirationDate
        cell.amountLabel.text = NumberFormatter.currencyFormatter().string(from: historyItem.amount ?? 0.0)
        cell.reasonLabel.text = historyItem.memo
        cell.checkNumberLabel.text = historyItem.checkNumber
        cell.payeeLabel.text = historyItem.payee
        cell.statusLabel.text = historyItem.status
    }
}

extension StopPaymentHistoryItemPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
