//
//  SnapshotDetailViewController.swift
//  Snapshot-iOS
//
//  Created by Elvin Bearden on 8/12/20.
//

import AccountsPresentation
import ComponentKit
import Localization
import Logging
import Network
import RxSwift
import ShimmeringData
import Snapshot
import SnapshotService
import UIKit
import UITableViewPresentation
import Utilities
import Views
import Analytics

class SnapshotDetailViewController: BaseSnapshotViewController {
    init(config: ComponentConfig, viewModel: SnapshotViewModel) {
        super.init(config: config, viewModel: viewModel, nibName: "\(type(of: self))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        title = l10nProvider.localize("launchPage.snapshot.button.label")
    }

    override func update(value: SnapshotViewModel.Value) {
        switch value {
        case .none:
            viewState = .loading

        case .snapshot, .widget:
            break

        case .detail(account: let account, transactions: let transactions):
            guard let transactions = transactions else {
                let header = SnapshotDetailHeader()
                header.configure(account: account, l10nProvider: l10nProvider)
                self.tableHeaderView = header

                viewState = .transactionsDisabled
                return
            }

            guard !transactions.isEmpty else {
                let header = SnapshotDetailHeader()
                header.configure(account: account, l10nProvider: l10nProvider)
                self.tableHeaderView = header

                viewState = .noTransactions
                return
            }
            
            let tableViewModel = model(
                account: account,
                transactions: transactions,
                contentSizeCategory: self.view.traitCollection.preferredContentSizeCategory
            )

            let header = SnapshotDetailHeader()
            header.configure(account: account, l10nProvider: l10nProvider)
            self.tableHeaderView = header
            viewState = .loaded(tableViewModel)

        case .error(error: let error):
            log.error("Snapshot detail loading error: \(error)", context: error)
            viewState = .error(error)
        }
    }

    private func model(account: Snapshot.Account,
                       transactions: [Snapshot.Transaction],
                       contentSizeCategory: UIContentSizeCategory) -> UITableViewModel {

        let rowType = contentSizeCategory.isAccessibilitySize ? ADATransactionRow.self : TransactionRow.self
        let transactionRows: [TransactionRow] = transactions.map {
            rowType.init(account: account, transaction: $0, l10nProvider: self.l10nProvider)
        }
        let transactionsHeader = SnapshotSectionHeader(title: l10nProvider.localize("launchPage.snapshot.detail.recent-transactions"))

        let sections: [UITableViewSection] = [
            UITableViewSection(
                rows: transactionRows,
                header: .presentable(AnyUITableViewHeaderFooterPresentable(transactionsHeader)),
                footer: .none
            )
        ]

        return UITableViewModel(sections: sections)
    }

    override func refresh() {
        refreshTransactions()
    }
}

extension SnapshotDetailViewController: TrackableScreen {
    public var screenName: String {
        return "Snapshot Detail"
    }
}
