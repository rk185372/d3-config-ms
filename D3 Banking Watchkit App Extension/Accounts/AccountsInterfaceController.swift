//
//  AccountsInterfaceController.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/23/18.
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

final class AccountsInterfaceController: SnapshotBasedInterfaceController {
    private var accounts: [Snapshot.Account] = []

    override var titleKey: String {
        return "watch.accounts.title"
    }

    override var loadingLabelKey: String {
        return "watch.accounts.loading"
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        isInitialized.subscribe(onNext: { [unowned self] (initialized) in
            if initialized {
                self.bindToViewModel()
            }
        }).disposed(by: bag)
    }

    func bindToViewModel() {
        viewModel
            .snapshot
            .drive(onNext: { [unowned self] (value) in
                self.update(snapshotValue: value)
            }).disposed(by: bag)

        viewModel
            .transactions
            .drive(onNext: { [unowned self] (value) in
                self.update(snapshotValue: value)
            }).disposed(by: bag)

        viewModel.fetch()
    }

    func update(snapshotValue value: SnapshotViewModel.Value) {
        switch value {
        case .none, .widget:
            viewState = .loading
        case .snapshot(let snapshot):
            if snapshot.isSingleAccount {
                viewState = .loading
            } else {
                processAccountData(snapshot.accounts)
                viewState = snapshot.accounts.count > 0 ? .loaded : .noAccounts
            }
        case .detail(account: let account, transactions: let transactions):
            processDetailData(account: account, transactions: transactions)
            viewState = .loaded
        case .error(let error):
            viewState = .error(error)
        }
    }

    private func processDetailData(account: Snapshot.Account, transactions: [Snapshot.Transaction]?) {
        let numberOfTransactions = transactions?.count ?? 0
        var rowTypes = Array(repeating: "TransactionRow", count: numberOfTransactions)
        rowTypes.insert("BankAccountHeaderRow", at: 0)

        if numberOfTransactions < 1 {
            rowTypes.append("NoTransactionsRow")
        }

        tableView.setRowTypes(rowTypes)

        if let transactions = transactions, transactions.isEmpty {
            if let row = tableView.rowController(at: 1) as? NoTransactionsRowController {
                row.titleLabel.setText(l10nProvider.localize("launchPage.snapshot.no-recent-transactions"))
            }
        } else if let transactions = transactions {
            transactions.enumerated().forEach { (index, transaction) in
                guard let row = tableView.rowController(at: index + 1) as? TransactionRowController else { return }
                guard let transactionDate = transaction.postDate else { return }

                row.amountLabel.setText(NumberFormatter.currencyFormatter().string(from: transaction.amount))
                row.transactionDescriptionLabel.setText(transaction.description)
                row.accountLabel.setText(account.name)
                row.monthLabel.setText(transactionDate.abbreviatedMonthString)
                row.dayLabel.setText(transactionDate.dayString)
            }
        } else {
            if let row = tableView.rowController(at: 1) as? NoTransactionsRowController {
                row.titleLabel.setText(l10nProvider.localize("launchPage.snapshot.no-transactions"))
            }
        }

        guard let row = tableView.rowController(at: 0) as? AccountRowController else { return }
        row.accountName.setText(account.name)

        if let balance = account.balance {
            row.accountBalance.setText(balance.formatted(currencyCode: account.currencyCode))
        } else {
            row.accountBalance.setHidden(true)
        }

        self.notEnabledLabel.setHidden(self.tableView.numberOfRows != 0)
    }

    private func processAccountData(_ accounts: [Snapshot.Account]) {
        self.accounts = accounts

        tableView.setNumberOfRows(accounts.count, withRowType: "BankAccountRow")

        accounts
            .enumerated().forEach { (index, account) in
                guard let row = tableView.rowController(at: index) as? AccountRowController else { return }

                row.accountName.setText(account.name)
                if let balance = account.balance {
                    row.accountBalance.setText(balance.formatted(currencyCode: account.currencyCode))
                } else {
                    row.accountBalance.setHidden(true)
                }
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        guard accounts.count > rowIndex else { return nil }
        let account = accounts[rowIndex]
        return account
    }
}

