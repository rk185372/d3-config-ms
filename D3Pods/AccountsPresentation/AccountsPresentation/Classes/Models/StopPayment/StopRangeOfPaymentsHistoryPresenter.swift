//
//  StopRangeOfPaymentsHistoryPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/20/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation
import Utilities

struct StopRangeOfPaymentsHistoryPresenter: UITableViewPresentable, Equatable {
    private let historyItem: StoppedPaymentHistoryItem

    init(historyItem: StoppedPaymentHistoryItem) {
        self.historyItem = historyItem
    }

    func configure(cell: StopRangeOfPaymentsHistoryCell, at indexPath: IndexPath) {
        cell.expirationDateLabel.text = historyItem.expirationDate
        cell.amountFromLabel.text = NumberFormatter.currencyFormatter().string(from: historyItem.amountFrom ?? 0.0)
        cell.amountToLabel.text = NumberFormatter.currencyFormatter().string(from: historyItem.amountTo ?? 0.0)
        cell.reasonLabel.text = historyItem.memo
        cell.checkFromLabel.text = historyItem.checkNumberFrom
        cell.checkToLabel.text = historyItem.checkNumberTo
        cell.payeeLabel.text = historyItem.payee
        cell.statusLabel.text = historyItem.status
    }

    static func == (lhs: StopRangeOfPaymentsHistoryPresenter, rhs: StopRangeOfPaymentsHistoryPresenter) -> Bool {
        return lhs.historyItem == rhs.historyItem
    }
}

extension StopRangeOfPaymentsHistoryPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
