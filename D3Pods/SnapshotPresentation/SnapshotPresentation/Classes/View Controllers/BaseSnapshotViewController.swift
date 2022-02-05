//
//  BaseSnapshotViewController.swift
//  SnapshotPresentation
//
//  Created by Elvin Bearden on 8/21/20.
//

import UIKit
import ComponentKit
import AccountsPresentation
import Localization
import Logging
import Network
import RxSwift
import ShimmeringData
import Snapshot
import SnapshotService
import UITableViewPresentation
import Utilities
import Views

public class BaseSnapshotViewController: UIViewControllerComponent {
    public enum ViewState {
        case loading
        case loaded(UITableViewModel)
        case noAccounts
        case noTransactions
        case transactionsDisabled
        case error(Error)
    }

    @IBOutlet weak var tableView: UITableView!

    var tableHeaderView: UIView?
    let viewModel: SnapshotViewModel
    var dataSource: UITableViewPresentableDataSource!
    var viewState: ViewState = .loading {
        willSet {
            switch newValue {
            case .loading:
                setTableViewLoading()
            case .loaded(let model):
                setTableViewDoneLoading(model: model)
            case .noAccounts:
                showNoAccountsMessage()
            case .noTransactions:
                showNoTransactionsMessage()
            case .transactionsDisabled:
                showTransactionsDisabledMessage()
            case .error(let error):
                setTableViewError(error)
            }
        }
    }

    private let noItemsView = NoItemsView()
    private let refreshControl = UIRefreshControl()

    init(config: ComponentConfig, viewModel: SnapshotViewModel, nibName: String) {
        self.viewModel = viewModel
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: nibName,
            bundle: SnapshotPresentationBundle.bundle
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        dataSource = UITableViewPresentableDataSource(tableView: tableView)

        viewModel.snapshot.drive(onNext: { [unowned self] (value) in
            self.update(value: value)
        }).disposed(by: bag)

        viewModel.transactions.drive(onNext: { [unowned self] (value) in
            self.update(value: value)
        }).disposed(by: bag)
    }

    func update(value: SnapshotViewModel.Value) {
        fatalError("Must be implemented by subclass")
    }
}

// MARK: - Private
private extension BaseSnapshotViewController {
    func setupButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        noItemsView.tryAgainButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
    }

    func setTableViewLoading() {
        dataSource.tableViewModel = .shimmeringDataModel
        tableView.backgroundView = nil
    }

    func setTableViewDoneLoading(model: UITableViewModel) {
        dataSource.tableViewModel = model
        tableView.backgroundView = nil
        refreshControl.endRefreshing()
        tableView.refreshControl = refreshControl

        if let header = tableHeaderView {
            tableView.tableHeaderView = header
            header.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
                maker.centerX.equalToSuperview()
            }
            tableView.layoutIfNeeded()
            tableView.tableHeaderView = header
        }
    }

    func showNoAccountsMessage() {
        dataSource.tableViewModel = UITableViewModel()
        noItemsView.infoLabel.text = l10nProvider.localize("launchPage.snapshot.no-accounts")
        noItemsView.tryAgainButton.isHidden = true
        noItemsView.refreshIcon.isHidden = true
        tableView.backgroundView = noItemsView
        refreshControl.endRefreshing()
        tableView.refreshControl = nil
    }

    func showTransactionsDisabledMessage() {
        dataSource.tableViewModel = UITableViewModel()
        noItemsView.infoLabel.text = l10nProvider.localize("launchPage.snapshot.no-transactions")
        noItemsView.tryAgainButton.isHidden = true
        noItemsView.refreshIcon.isHidden = true
        tableView.backgroundView = noItemsView
        refreshControl.endRefreshing()
        tableView.refreshControl = nil
        tableView.separatorStyle = .none

        if let header = tableHeaderView {
            tableView.tableHeaderView = header
            header.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
                maker.centerX.equalToSuperview()
            }
            tableView.layoutIfNeeded()
            tableView.tableHeaderView = header
        }
    }

    func showNoTransactionsMessage() {
        dataSource.tableViewModel = UITableViewModel()
        noItemsView.infoLabel.text = l10nProvider.localize("launchPage.snapshot.no-recent-transactions")
        noItemsView.tryAgainButton.isHidden = true
        noItemsView.refreshIcon.isHidden = true
        tableView.backgroundView = noItemsView
        refreshControl.endRefreshing()
        tableView.refreshControl = nil
        tableView.separatorStyle = .none

        if let header = tableHeaderView {
            tableView.tableHeaderView = header
            header.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
                maker.centerX.equalToSuperview()
            }
            tableView.layoutIfNeeded()
            tableView.tableHeaderView = header
        }
    }

    func setTableViewError(_ error: Error) {
        dataSource.tableViewModel = UITableViewModel()
        noItemsView.infoLabel.text = message(forError: error)
        noItemsView.tryAgainButton.isHidden = true
        tableView.backgroundView = noItemsView
        refreshControl.endRefreshing()
        tableView.refreshControl = nil
    }

    func message(forError error: Error) -> String {
        switch error {
        case ResponseError.failureWithMessage(let message):
            return message
        case SnapshotError.sync(let status):
            return l10nProvider.localize(status.errorMessageKey)
        default:
            return l10nProvider.localize("dashboard.quick-view.marketing-message")
        }
    }

    @objc func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Refreshing
public extension BaseSnapshotViewController {
    @objc func refresh() {
        refreshSnapshot()
    }

    func refreshSnapshot() {
        viewModel.fetch()
    }

    func refreshTransactions() {
        guard let account = viewModel.selectedAccount else { return }
        viewModel.fetchTransactions(for: account)
    }
}
