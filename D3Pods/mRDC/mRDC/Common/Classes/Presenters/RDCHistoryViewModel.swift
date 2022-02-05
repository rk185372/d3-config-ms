//
//  RDCHistoryViewModel.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/2/18.
//

import Foundation
import Localization
import Logging
import RxSwift
import UITableViewPresentation
import Utilities

protocol RDCHistoryViewDelegate: class {
    func endLoading()
    func selectedTransactionItem(item: DepositTransaction)
    func handleDepositButtonTouched()
}

final class RDCHistoryViewModel {

    private enum LoadingState {
        case animating
        case notAnimating
    }
    
    weak var historyViewDelegate: RDCHistoryViewDelegate?
    
    private var dataSource: UITableViewPresentableDataSource!
    private var standardSections: [UITableViewSection]
    private var deposits: [DepositTransaction]?
    
    private let rdcService: RDCService
    private let device: Device
    private let l10nProvider: L10nProvider
    private let bag = DisposeBag()
    
    init(rdcService: RDCService, device: Device, l10nProvider: L10nProvider) {
        self.rdcService = rdcService
        self.device = device
        self.l10nProvider = l10nProvider

        self.standardSections = [
            UITableViewSection(
                rows: [
                    AnyUITableViewPresentable(DepositButtonPresenter(l10nProvider: l10nProvider))
                ]
            ),
            UITableViewSection(
                rows: [
                    AnyUITableViewPresentable(DepositDelayInfoPresenter())
                ]
            )
        ]
    }
    
    func configureDataSource(tableView: UITableView) {
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)
        dataSource.tableViewModel = UITableViewModel(sections: standardSections)
    }
    
    @objc func getDeposits(showSpinner: Bool) {
        //Clear any existing data
        clearSavedData()

        var sections = standardSections

        if showSpinner {
            sections.append(UITableViewSection(rows: [AnyUITableViewPresentable(HistoryLoadingPresenter())]))
        }

        dataSource.tableViewModel = UITableViewModel(sections: sections)

        //fetch accounts
        getDepositTransactions()
    }
    
    private func clearSavedData() {
        deposits = nil
    }
    
    private func getDepositTransactions() {
        rdcService
            .getHistory(withUuid: device.uuid)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .success(let response):
                    if response.isEmpty {
                        self.updateTableViewForNoHistory()
                    } else {
                        self.deposits = response
                        self.updateTableView()
                    }
                case .error(let error):
                    log.error(error)
                    self.updateTableViewForHistoryFailure()
                }
                
                self.historyViewDelegate?.endLoading()
            })
            .disposed(by: bag)
    }
    
    private func updateTableView() {
        //Parse the data by day
        guard let deposits = deposits else {
            return
        }
        
        class TransactionsGroup {
            let title: String
            var transactions: [DepositTransaction]
            
            init(title: String, transactions: [DepositTransaction]) {
                self.title = title
                self.transactions = transactions
            }
        }

        var sections: [UITableViewSection] = [
            UITableViewSection(
                rows: [
                    AnyUITableViewPresentable(DepositButtonPresenter(l10nProvider: l10nProvider))
                ]
            ),
            UITableViewSection(
                rows: [
                    AnyUITableViewPresentable(DepositDelayInfoPresenter())
                ]
            )
        ]

        sections += deposits
            .reduce(into: [TransactionsGroup]()) { (result, transaction) in
                if let currentSection = result.last, currentSection.title == transaction.dateString() {
                    currentSection.transactions.append(transaction)
                } else {
                    result += [TransactionsGroup(title: transaction.dateString()!, transactions: [transaction])]
                }
            }.map {
                UITableViewSection(
                    rows: $0.transactions.map { RDCDepositTransactionPresenter(depositTransaction: $0) },
                    header: .presentable(.init(RDCDepositTransactionHeaderPresenter(dateString: $0.title)))
                )
        }

        self.dataSource.tableViewModel = UITableViewModel(sections: sections)
    }

    private func updateTableViewForNoHistory() {
        var sections = standardSections

        sections.append(
            UITableViewSection(rows: [AnyUITableViewPresentable(NoHistoryPresenter())])
        )

        dataSource.tableViewModel = UITableViewModel(sections: sections)
    }

    private func updateTableViewForHistoryFailure() {
        var sections = standardSections

        let failedToLoadPresenter = FailedToLoadPresenter(
            infoText: l10nProvider.localize("dashboard.widget.deposit.history.error.title"),
            target: self,
            selector: #selector(retryButtonTouched(_:)),
            event: .touchUpInside
        )

        sections.append(
            UITableViewSection(rows: [AnyUITableViewPresentable(failedToLoadPresenter)])
        )

        dataSource.tableViewModel = UITableViewModel(sections: sections)
    }

    @objc private func retryButtonTouched(_ sender: UIButton) {
        self.getDeposits(showSpinner: true)
    }
}

extension RDCHistoryViewModel: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch presentable.base {
        case is RDCDepositTransactionPresenter:
            historyViewDelegate?.selectedTransactionItem(
                item: (presentable.base as! RDCDepositTransactionPresenter).transaction
            )
        case is DepositButtonPresenter:
            historyViewDelegate?.handleDepositButtonTouched()
        default:
            log.debug("Unkown Presenter")
        }

    }
}
