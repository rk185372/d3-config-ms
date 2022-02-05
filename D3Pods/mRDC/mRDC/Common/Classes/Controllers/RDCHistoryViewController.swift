//
//  RDCHistoryViewController.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/27/18.
//

import Foundation
import InAppRatingApi
import ComponentKit
import Localization
import Analytics
import SnapKit
import Views
import RxSwift
import RxRelay

final class RDCHistoryViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var errorLabel: UILabelComponent!
    
    private let historyViewModel: RDCHistoryViewModel
    private let rdcDepositTransactionDetailViewControllerFactory: RDCDepositTransactionDetailViewControllerFactory
    private let depositViewControllerFactory: RDCDepositViewControllerFactory
    private let inAppRatingManager: InAppRatingManager
    
    private let loadingView = LoadingView()
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcHistoryViewModel: RDCHistoryViewModel,
         rdcDepositTransactionDetailViewControllerFactory: RDCDepositTransactionDetailViewControllerFactory,
         depositViewControllerFactory: RDCDepositViewControllerFactory,
         inAppRatingManager: InAppRatingManager) {
        self.historyViewModel = rdcHistoryViewModel
        self.rdcDepositTransactionDetailViewControllerFactory = rdcDepositTransactionDetailViewControllerFactory
        self.depositViewControllerFactory = depositViewControllerFactory
        self.inAppRatingManager = inAppRatingManager
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupPresenter()
        
        setupRefreshControl()
        
        NotificationCenter
            .default
            .rx
            .notification(.depositSuccessful)
            .subscribe(onNext: { [unowned self] _ in
                self.historyViewModel.getDeposits(showSpinner: true)
            })
            .disposed(by: bag)

        navigationItem.title = l10nProvider.localize("dashboard.widget.deposit.history.title")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inAppRatingManager.engage(event: "rdc:viewed", fromViewController: self)
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl(sender:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.sectionHeaderHeight = 44
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(displayP3Red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.04)
        tableView.backgroundView = nil
    }
    
    func setupPresenter() {
        historyViewModel.configureDataSource(tableView: tableView)
        historyViewModel.historyViewDelegate = self
        historyViewModel.getDeposits(showSpinner: true)
    }
    
    @objc private func didPullRefreshControl(sender: UIRefreshControl) {
        historyViewModel.getDeposits(showSpinner: false)
    }
}

extension RDCHistoryViewController: RDCHistoryViewDelegate {
    
    func endLoading() {
        if tableView.refreshControl?.isRefreshing ?? false {
            tableView.refreshControl?.endRefreshing()
        }
        
        loadingView.removeFromSuperview()
    }
    
    func selectedTransactionItem(item: DepositTransaction) {
        //show the deposit details
        let detailVC = rdcDepositTransactionDetailViewControllerFactory.create(depositTransaction: item)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }

    func handleDepositButtonTouched() {
        let depositViewController = depositViewControllerFactory.create()
        depositViewController.delegate = self

        let viewController = UINavigationControllerComponent(rootViewController: depositViewController)

        present(viewController, animated: true, completion: nil)
    }
}

extension RDCHistoryViewController: RDCDepositFlowDelegate {
    func depositFlowDidFinish(success: Bool) {
        dismiss(animated: true) {
            (self.navigationController as? UINavigationControllerComponent)?.setNeedsNavigationStyleAppearanceUpdate()
            if success {
                self.inAppRatingManager.engage(event: "RDC", fromViewController: self)
            }
        }
    }
}

extension RDCHistoryViewController: TrackableScreen {
    var screenName: String {
        return "RDC History"
    }
}
