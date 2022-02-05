//
//  TransactionsTodayViewController.swift
//  D3 Transactions Today Extension
//
//  Created by Branden Smith on 2/19/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import Snapshot
import SnapshotService
import TodayExtension
import UITableViewPresentation

final class TransactionsTodayViewController: TodayViewController {
    override func snapshotState(given snapshotValue: SnapshotViewModel.Value) -> SnapshotState {
        switch snapshotValue {
        case .none, .snapshot, .detail:
            return .loading
        case .error(let error):
            return .error(message: message(forError: error))
        case .widget(widget: let widget):
            guard let transactions = widget.transactions else {
                return .error(message: l10nProvider.localize("launchPage.snapshot.no-transactions"))
            }
            guard !transactions.isEmpty else {
                return .error(message: l10nProvider.localize("launchPage.snapshot.no-recent-transactions"))
            }
            return .complete(
                model: UITableViewModel(
                    rows: (view.traitCollection.preferredContentSizeCategory.isAccessibilitySize)
                        ? transactions.map({ ADATransactionRow(transaction: $0, l10nProvider: l10nProvider) })
                        : transactions.map({ TransactionRow(transaction: $0, l10nProvider: l10nProvider) })
                )
            )
        }
    }
}
