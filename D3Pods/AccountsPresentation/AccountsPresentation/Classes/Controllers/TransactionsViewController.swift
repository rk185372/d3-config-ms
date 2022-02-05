//
//  TransactionsViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/15/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import UIKit
import UITableViewPresentation
import Utilities
import D3Accounts
import Transactions
import Analytics
import ShimmeringData
import ComponentKit
import Localization
import Views

final class TransactionsViewController: UIViewControllerComponent {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var headerContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var searchBar: UISearchBar!

    private var balanceHeaderView: BalanceHeaderView?
    private var dataSource: UITableViewPresentableDataSource!
    private var previousScrollViewOffset: CGFloat = 0.0
    private var refreshControl = UIRefreshControl()
    
    private let account: AccountListItem
    private let transactionService: TransactionsService
    private let accountDetailsViewControllerFactory: AccountDetailsViewControllerFactory
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         account: AccountListItem,
         transactionService: TransactionsService,
         accountDetailsViewControllerFactory: AccountDetailsViewControllerFactory) {
        self.account = account
        self.transactionService = transactionService
        self.accountDetailsViewControllerFactory = accountDetailsViewControllerFactory
        super.init(l10nProvider: l10nProvider,
                   componentStyleProvider: componentStyleProvider,
                   nibName: String(describing: type(of: self)),
                   bundle: AccountsPresentationBundle.bundle)

        // We want to set the back bar button item to one with no title so that in the AccountDetailsViewController, the back
        // bar button item has no title. 
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = account.name
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.sectionHeaderHeight = UITableView.automaticDimension

        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        setupRefreshControl()
        setupBalanceHeaderView()
        getTransactions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableViewInsets()
    }
    
    private func adjustTableViewInsets() {
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
        tableView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }
    
    private func setupRefreshControl() {
        refreshControl.removeTarget(nil, action: #selector(didPullRefreshControl(sender:)), for: .allEvents)
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl(sender:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }

    private func removeRefreshControl() {
        tableView.refreshControl = nil
    }
    
    private func setupBalanceHeaderView() {
        headerContainerView.subviews.forEach({ $0.removeFromSuperview() })

        if !view.traitCollection.preferredContentSizeCategory.isAccessibilitySize {
            balanceHeaderView = StandardBalanceHeaderView(
                frame: CGRect(origin: headerContainerView.bounds.origin, size: CGSize(width: view.bounds.width, height: 98.0))
            )
            headerContainerViewHeightConstraint.constant = 98.0
        } else {
            balanceHeaderView = ADABalanceHeaderView(
                frame: CGRect(origin: headerContainerView.bounds.origin, size: CGSize(width: view.bounds.width, height: 175.5))
            )
            headerContainerViewHeightConstraint.constant = 175.5
        }

        // We want to remove any targets from the balanceHeaderView's manageButton and add self as a target.
        balanceHeaderView?.manageButton.removeTarget(nil, action: nil, for: .allEvents)
        balanceHeaderView?.manageButton.addTarget(self, action: #selector(manageButtonTouched(_:)), for: .touchUpInside)
        
        (balanceHeaderView as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(balanceHeaderView as! UIView)
        (balanceHeaderView as? UIView)?.makeMatch(view: headerContainerView)

        // TODO: Available balance needs to go away because it isn't present in the API, when we come in to do the transactions
        // header it will be removed. 
        balanceHeaderView?.updateView(
            withName: account.displayableName,
            balance: NumberFormatter.currencyFormatter(currencyCode: account.currencyCode).string(from: account.balance) ?? "",
            accountNumber: account.accountNumber.map({ String($0.suffix(5)) }) ?? "",
            status: account.status
        )
    }
    
    private func setLoadingDataSource() {
        dataSource.tableViewModel = .shimmeringDataModel
        
        tableView.reloadData()
    }
    
    private func getTransactions() {
        setLoadingDataSource()
        self.tableView.backgroundView = nil
        
        transactionService
            .getTransactions(accountID: account.id)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .success(let transactionResponse):
                    self.tableView.separatorStyle = .singleLine
                    self.tableView.tableHeaderView = self.searchBar
                    self.dataSource.tableViewModel = self.createTableViewModel(transactionResponse.results)
                    self.tableView.refreshControl?.isEnabled = true
                    self.setupRefreshControl()
                case .error:
                    self.dataSource.tableViewModel = []
                    let noItemsView = NoItemsView(frame: self.tableView.bounds)
                    // TODO: This will need to be an L10n when we have one to use.
                    noItemsView.infoLabel.text = "Failed to load transactions."
                    noItemsView.tryAgainButton.addTarget(self, action: #selector(self.tryAgainButtonTouched(_:)), for: .touchUpInside)
                    self.tableView.separatorStyle = .none
                    self.tableView.backgroundView = noItemsView
                    self.tableView.tableHeaderView = nil
                    self.removeRefreshControl()
                }
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            })
            .disposed(by: bag)
    }
    
    private func createTableViewModel(_ transactions: [Transaction]) -> UITableViewModel {
        let dates: [Date] = transactions.map({ $0.date }).uniqueElements.sorted(by: { (date1, date2) -> Bool in
            date1.compare(date2) == .orderedDescending
        })
        
        let sections: [UITableViewSection] = dates.map({ date -> UITableViewSection in
            let presentables = transactions.filter({ transaction in
                return transaction.date == date
            }).map({ transaction in
                TransactionPresenter(transaction: transaction)
            })
            
            return UITableViewSection(
                rows: presentables,
                header: .presentable(
                    AnyUITableViewHeaderFooterPresentable(
                        AccountsSectionHeaderPresenter(title: date.longStyleStringExcludingTime)
                    )
                )
            )
        })
        
        return UITableViewModel(sections: sections)
    }
    
    @objc private func didPullRefreshControl(sender: UIRefreshControl) {
        getTransactions()
    }

    @objc private func contentSizeCategoryDidChange(_ sender: Notification) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        setupBalanceHeaderView()
    }

    @objc private func manageButtonTouched(_ sender: UIButton) {
        let accountDetailsController = accountDetailsViewControllerFactory.create(account: account)
        navigationController?.pushViewController(accountDetailsController, animated: true)
    }

    @objc private func tryAgainButtonTouched(_ sender: UIButton) {
        getTransactions()
    }
}

extension TransactionsViewController: TrackableScreen {
    var screenName: String {
        return "Accounts/Transactions"
    }
}

extension TransactionsViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let absoluteTop: CGFloat = 0
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height

        let scrollViewDiff = scrollView.contentOffset.y - previousScrollViewOffset
        let isScrollingDown = scrollViewDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollViewDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        balanceHeaderView?.updateHeight(
            withTableView: tableView,
            given: scrollViewDiff,
            previousScrollViewOffset: previousScrollViewOffset,
            isScrollingUp: isScrollingUp,
            isScrollingDown: isScrollingDown
        )

        headerContainerViewHeightConstraint.constant = balanceHeaderView?.currentHeight ?? 98.0
        previousScrollViewOffset = scrollView.contentOffset.y
    }
}
