//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Branden Smith on 2/19/19.
//

import AppConfiguration
import ComponentKit
import Dip
import Localization
import LocalizationData
import Network
import NotificationCenter
import RxSwift
import Snapshot
import SnapshotService
import UIKit
import UITableViewPresentation
import Utilities

public enum SnapshotState {
    case loading
    case error(message: String)
    case complete(model: UITableViewModel)
}

open class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabelComponent!
    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    private let userDefaults = UserDefaults(suiteName: AppConfiguration.applicationGroup)!
    private var snapshotViewModel: SnapshotViewModel!

    public var dataSource: UITableViewPresentableDataSource!

    public var l10nProvider: L10nProvider!
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "TodayViewController", bundle: nil)
        self.l10nProvider = LoadL10NProvider()
    }
    
    private var snapshotToken: String? {
       return AuthUserStore(userDefaults: userDefaults).snapshotToken
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        self.showActivityIndicator()

        // today extensions are not supposed to scroll, page will scroll and the view should be the height it requires...
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = UITableViewPresentableDataSource(tableView: tableView)
    }

    open func snapshotState(given snapshotValue: SnapshotViewModel.Value) -> SnapshotState {
        fatalError("This method must be overriden in a subclass")
    }

    public func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        let heightOfRows = calculateTotalHeight(givenMaxHeight: maxSize.height)
        let maxHeight = maxSize.height <= heightOfRows ? maxSize.height : heightOfRows

        preferredContentSize = expanded
            ? CGSize(width: maxSize.width, height: maxHeight)
            : CGSize(width: maxSize.width, height: maxSize.height)
    }

    public func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // This is called initially and can be called at any time later. Because of this,
        // we are making sure we have a snapshot token before we do anything. If we have one
        // we will proceed, if not we will show the user the enable snapshot error. If the
        // token becomes available at any time and this method is called after we will let
        // the user through and create the snapshot model. We do this here becasue we
        // can't be sure that viewDidLoad will be called again to update the token in
        // the snapshot view model.
        guard snapshotToken != nil else {
            showError(message: l10nProvider.localize("dashboard.quick-view.marketing-message"))
            return
        }

        // If the snapshotViewModel is nil we will set it up
        // if it is not nil we will call fetch to update the snapshot.
        guard snapshotViewModel != nil else {
            setupSnapshotViewModel()
            snapshotViewModel
                .snapshotWidget
                .drive(onNext: { [unowned self] value in
                    let state = self.snapshotState(given: value)

                    switch state {
                    case .loading:
                        self.showActivityIndicator()
                    case .error(let message):
                        self.showError(message: message)
                        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
                    case .complete(let tableViewModel):
                        self.dataSource.tableViewModel = tableViewModel
                        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
                        self.showTableView()
                    }
                })
                .disposed(by: bag)

            snapshotViewModel.fetchWidget()

            return
        }

        snapshotViewModel.fetchWidget()
    }

    private func setupSnapshotViewModel() {
        self.snapshotViewModel = SnapshotViewModel(
            service: SnapshotServiceItem(
                client: Client(domain: AppConfiguration.restServer.url)
            ),
            token: snapshotToken ?? "",
            uuid: userDefaults.value(key: KeyStore.uuid) ?? ""
        )
    }

    private func calculateTotalHeight(givenMaxHeight maxHeight: CGFloat) -> CGFloat {
        var totalHeight = CGFloat(0)

        for i in 0..<dataSource.numberOfSections(in: tableView) {
            for j in 0..<dataSource.tableView(tableView, numberOfRowsInSection: i) {
                let cellHeight = tableView.rectForRow(at: IndexPath(row: j, section: i)).size.height
                // This will allow us to avoid cutting any cell off when the widget is
                // fully expanded.
                if (totalHeight + cellHeight) > maxHeight {
                    return totalHeight
                } else {
                    totalHeight += cellHeight
                }
            }
        }

        return totalHeight
    }

    public func message(forError error: Error) -> String {
        switch error {
        case ResponseError.failureWithMessage(let message):
            return message
        case SnapshotError.sync(let status):
            return l10nProvider.localize(status.errorMessageKey)
        default:
            return l10nProvider.localize("dashboard.quick-view.marketing-message")
        }
    }

    private func showError(message: String) {
        tableView.isHidden = true
        errorLabel.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        errorLabel.text = message
    }

    private func showTableView() {
        tableView.isHidden = false
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showActivityIndicator() {
        tableView.isHidden = true
        errorLabel.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func LoadL10NProvider() -> L10n {
        let l10n = L10n()
        
        // 1 - Business Login
        if AuthUserStore(userDefaults: userDefaults).lastLoggedInAccount == 1 {
            l10n.loadLocalizations(
                resources: LocalizationDataProvider().BusinessLocalizableData(),
                completion: nil
            )
        } else {
            l10n.loadLocalizations(
                resources: LocalizationDataProvider().ConsumerLocalizableData(),
                completion: nil
            )
        }
        
        return l10n
    }
}
