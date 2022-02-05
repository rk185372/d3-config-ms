//
//  SnapshotViewController.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/13/18.
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
import CompanyAttributes
import Web

public final class SnapshotViewController: BaseSnapshotViewController {
    private var snapshot: Snapshot!
    private unowned let snapshotFactory: SnapshotViewControllerFactory
    private let configurationSettings: ConfigurationSettings
    private var isAccountBadgeEnabled: Bool
    
    init(config: ComponentConfig, viewModel: SnapshotViewModel,
         factory: SnapshotViewControllerFactory,
         configurationSettings: ConfigurationSettings) {
        self.snapshotFactory = factory
        self.configurationSettings = configurationSettings
        self.isAccountBadgeEnabled = self.configurationSettings.config?.common?.showAvatars ?? false
        
        super.init(config: config, viewModel: viewModel, nibName: "\(type(of: self))")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = l10nProvider.localize("launchPage.snapshot.button.label")
        dataSource.delegate = self
        tableView.allowsSelection = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        viewModel.fetch()
    }

    override func update(value: SnapshotViewModel.Value) {
        switch value {
        case .none:
            viewState = .loading

        case .detail, .widget:
            break
            
        case .snapshot(let snapshot):
            // There can be accounts without transactions, but there can
            // never be transactions without accounts so if there are no
            // accounts we skip out and show the user a message.
            guard !snapshot.accounts.isEmpty else {
                viewState = .noAccounts
                return
            }

            self.snapshot = snapshot

            if snapshot.isSingleAccount {
                let controller = snapshotFactory.createDetail(viewModel: viewModel)
                navigationController?.setViewControllers([controller], animated: false)
            } else {
                let tableViewModel = model(
                    forSnapshot: snapshot,
                    contentSizeCategory: view.traitCollection.preferredContentSizeCategory
                )

                viewState = .loaded(tableViewModel)
            }

        case .error(let error):
            log.error("Snapshot loading error: \(error)", context: error)
            viewState = .error(error)
        }
    }
    
    private func model(forSnapshot snapshot: Snapshot, contentSizeCategory: UIContentSizeCategory) -> UITableViewModel {
        let accounts = snapshot.accounts
        let rowType = contentSizeCategory.isAccessibilitySize ? ADAAccountRow.self : AccountRow.self

        let accountRows = Dictionary(grouping: accounts, by: { $0.group })
            .mapValues { $0.map { rowType.init(account: $0, l10nProvider: l10nProvider, isAccountBadgeEnabled: isAccountBadgeEnabled) } }

        let sections: [UITableViewSection] = accountRows
            .sorted(by: { $0.key < $1.key })
            .map { (title, rows) -> UITableViewSection in

                let header = SnapshotSectionHeader(title: l10nProvider.localize("accounts.account-group.\(title)"))
                return UITableViewSection(
                    rows: rows,
                    header: .presentable(AnyUITableViewHeaderFooterPresentable(header)),
                    footer: .none
                )
        }

        return UITableViewModel(sections: sections)
    }
}

// MARK: - TrackableScreen
extension SnapshotViewController: TrackableScreen {
    public var screenName: String {
        return "Snapshot"
    }
}

// MARK: - Actions
extension SnapshotViewController {
    @objc private func contentSizeCategoryDidChange(_ sender: Notification) {
        let contentSizeCategory = UIContentSizeCategory(rawValue: sender.userInfo!["UIContentSizeCategoryNewValueKey"] as! String)

        dataSource.tableViewModel = model(
            forSnapshot: snapshot,
            contentSizeCategory: contentSizeCategory
        )
    }
}

// MARK: - UITableViewPresentableDataSourceDelegate
extension SnapshotViewController: UITableViewPresentableDataSourceDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = dataSource.tableViewModel[indexPath].base as? AccountRow else { return }

        viewModel.selectedAccount = row.account

        let controller = snapshotFactory.createDetail(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}
