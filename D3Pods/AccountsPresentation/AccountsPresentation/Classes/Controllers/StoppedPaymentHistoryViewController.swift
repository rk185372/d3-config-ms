//
//  StoppedPaymentHistoryViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/16/18.
//

import D3Accounts
import Foundation
import Network
import RxSwift
import ShimmeringData
import UIKit
import UITableViewPresentation
import ComponentKit

final class StoppedPaymentHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let account: Account
    private let serviceItem: AccountsService
    private let bag = DisposeBag()

    private var dataSource: UITableViewPresentableDataSource!

    private var historyHeader: AnyUITableViewHeaderFooterPresentable {
        return .init(CardControlsSectionHeaderPresenter(title: "From: \(account.name)"))
    }

    init(account: Account, serviceItem: AccountsService) {
        self.account = account
        self.serviceItem = serviceItem
        super.init(nibName: String(describing: type(of: self)), bundle: AccountsPresentationBundle.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review Stopped Payment History"

        dataSource = UITableViewPresentableDataSource(tableView: tableView)

        getHistoryItems()
    }

    private func getHistoryItems() {
        // Make the table view's background nil incase we were showing an error before.
        tableView.backgroundView = nil

        // Set the table view model to a shimmering model for the loading state.
        let shimmeringRow = ShimmeringDataPresenter<ShimmeringStopPaymentHistoryCell>(bundle: AccountsPresentationBundle.bundle)

        self.dataSource.tableViewModel = [
            UITableViewSection(rows: [shimmeringRow], header: .presentable(self.historyHeader), footer: .blank)
        ]

        serviceItem
            .getStoppedPaymentHistory(forAccountWithId: account.id)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .success(let items):
                    self.updateTableViewModel(with: items)
                case .error:
                    self.updateViewForError()
                }
            })
            .disposed(by: bag)
    }

    private func updateTableViewModel(with array: [StoppedPaymentHistoryItem]) {
        let rows = array.map { (item: StoppedPaymentHistoryItem) -> AnyUITableViewPresentable in
            if item.type == .single {
                return AnyUITableViewPresentable(StopPaymentHistoryItemPresenter(historyItem: item))
            }

            return AnyUITableViewPresentable(StopRangeOfPaymentsHistoryPresenter(historyItem: item))
        }

        self.dataSource.tableViewModel = [
            UITableViewSection(rows: rows, header: .presentable(self.historyHeader), footer: .blank)
        ]
    }

    private func updateViewForError() {
        self.dataSource.tableViewModel = []

        let noItemsView = NoItemsView()
        noItemsView.infoLabel.text = "Failed to load stopped payment history."
        noItemsView.infoLabel.textColor = .white
        noItemsView.tryAgainButton.setTitleColor(.white, for: .normal)
        noItemsView.tryAgainButton.addTarget(self, action: #selector(tryAgainButtonTouched(_:)), for: .touchUpInside)
        noItemsView.refreshIcon.tintColor = .white
        noItemsView.subviews.first?.backgroundColor = UIColor(
            displayP3Red: 58.0 / 255.0,
            green: 125.0 / 255.0,
            blue: 159.0 / 255.0,
            alpha: 1.0
        )

        tableView.backgroundView = noItemsView
    }

    @objc private func tryAgainButtonTouched(_ sender: UIButton) {
        getHistoryItems()
    }
}
