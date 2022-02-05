//
//  TransactionsInterfaceController.swift
//  D3 Banking
//
//  Created by Branden Smith on 10/22/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Dip
import Foundation
import Localization
import Logging
import RxSwift
import Snapshot
import SnapshotService
import Utilities
import WatchConnectivity
import WatchKit

final class TransactionsInterfaceController: SnapshotBasedInterfaceController {
    override var titleKey: String {
        return "watch.transactions.title"
    }

    override var loadingLabelKey: String {
        return "watch.transactions.loading"
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let account = context as? Snapshot.Account else { return }

        isInitialized.subscribe(onNext: { [unowned self] (initialized) in
            if initialized {
                self.bindToViewModel(account: account)
            }
        }).disposed(by: bag)
    }

    private func bindToViewModel(account: Snapshot.Account) {
        viewModel
            .transactions
            .drive(onNext: { [unowned self] (value) in
                self.update(snapshotValue: value)
            }).disposed(by: bag)

        viewModel.fetchTransactions(for: account)
    }

    func update(snapshotValue value: SnapshotViewModel.Value) {
        switch value {
        case .none, .snapshot, .widget:
            viewState = .loading
        case .error(let error):
            viewState = .error(error)
        case .detail(account: let account, transactions: let transactions):
            processDetailData(account: account, transactions: transactions)
            viewState = .loaded
        }
    }

    private func processDetailData(account: Snapshot.Account, transactions: [Snapshot.Transaction]?) {
        guard let transactions = transactions else {
            tableView.setNumberOfRows(1, withRowType: "NoTransactionsRow")
            if let row = tableView.rowController(at: 0) as? NoTransactionsRowController {
                row.titleLabel.setText(l10nProvider.localize("launchPage.snapshot.no-transactions"))
            }
            return
        }

        guard !transactions.isEmpty else {
            tableView.setNumberOfRows(1, withRowType: "NoTransactionsRow")
            if let row = tableView.rowController(at: 0) as? NoTransactionsRowController {
                row.titleLabel.setText(l10nProvider.localize("launchPage.snapshot.no-recent-transactions"))
            }
            return
        }
        
        tableView.setNumberOfRows(transactions.count, withRowType: "TransactionRow")

        transactions.enumerated().forEach { (index, transaction) in
            guard let row = tableView.rowController(at: index) as? TransactionRowController else { return }
            guard let transactionDate = transaction.postDate else { return }

            row.amountLabel.setText(NumberFormatter.currencyFormatter().string(from: transaction.amount))
            row.transactionDescriptionLabel.setText(transaction.description)
            row.accountLabel.setText(account.name)
            row.monthLabel.setText(transactionDate.abbreviatedMonthString)
            row.dayLabel.setText(transactionDate.dayString)
        }

        self.notEnabledLabel.setHidden(self.tableView.numberOfRows != 0)
    }
}
