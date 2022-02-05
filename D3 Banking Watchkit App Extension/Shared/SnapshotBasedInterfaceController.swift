//
//  SnapshotBasedInterfaceController.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 4/17/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Dip
import Foundation
import Localization
import Logging
import RxCocoa
import RxSwift
import Snapshot
import SnapshotService
import Utilities
import WatchConnectivity
import WatchKit

class SnapshotBasedInterfaceController: WKInterfaceController {
    enum ViewState {
        case loading
        case loaded
        case noAccounts
        case noTransactions
        case error(Error)
    }

    @IBOutlet var notEnabledLabel: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var loadingGroup: WKInterfaceGroup!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var loadingImage: WKInterfaceImage!

    private var defaultsRetriver: DefaultsRetriever!
    private var snapshotSubscription: Disposable?
    private var transactionsSubscription: Disposable?

    var l10nProvider: L10nProvider!
    var bag = DisposeBag()
    let isInitialized = BehaviorRelay<Bool>(value: false)
    var viewModel: SnapshotViewModel!
    var viewState: ViewState = .loading {
        willSet {
           switch newValue {
            case .loading:
                updateForLoadingState()
            case .loaded:
                updateForLoadedState()
            case .noAccounts, .noTransactions:
                updateForNotEnabledState()
            case .error(let error):
                updateForErrorState(error)
            }
        }
    }

    // These are meant to be overriden
    var titleKey: String {
        return ""
    }

    var loadingLabelKey: String {
        return ""
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        self.l10nProvider = try! DependencyContainer.shared.resolve()
        self.defaultsRetriver = try! DependencyContainer.shared.resolve()

        defaultsRetriver
            .rx
            .defaultsStatus
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] defaultsStatus in
                switch defaultsStatus {
                case .loading:
                    self.updateForLoadingState()
                case .complete(let snapshotToken, uuid: let uuid):
                    self.viewModel = SnapshotViewModel(
                        service: try! DependencyContainer.shared.resolve(),
                        token: snapshotToken,
                        uuid: uuid
                    )
                    self.isInitialized.accept(true)
                case .notEnabled:
                    self.updateForNotEnabledState()
                }
            })
            .disposed(by: bag)
    }

    override func willActivate() {
        super.willActivate()

        setTitle(l10nProvider.localize(titleKey))
        loadingLabel.setText(l10nProvider.localize(loadingLabelKey))
        notEnabledLabel.setText(l10nProvider.localize("watch.error.snapshot"))
    }

    private func updateForLoadingState() {
        D3Spinner().startSpinner(loadingImage)
        self.loadingGroup.setHidden(false)
        self.notEnabledLabel.setHidden(true)
        self.tableView.setHidden(true)
    }

    private func updateForErrorState(_ error: Error? = nil) {
        log.error("Snapshot loading error", context: error)

        let errorMessage: String
        if let error = error as? SnapshotError {
            errorMessage = l10nProvider.localize(error.errorLocalizedKey)
        } else {
            errorMessage = l10nProvider.localize("watch.error.network-unavailable")
        }

        self.presentAlert(
            withTitle: "Alert",
            message: errorMessage,
            preferredStyle: .alert,
            actions: [
                WKAlertAction(title: "Ok", style: .default) {
                    self.pop()
                }
            ]
        )

        D3Spinner().stopSpinner(loadingImage)
        self.loadingGroup.setHidden(true)
        self.notEnabledLabel.setHidden(true)
        self.tableView.setHidden(true)
    }

    private func updateForLoadedState() {
        D3Spinner().stopSpinner(loadingImage)
        self.loadingGroup.setHidden(true)
        self.notEnabledLabel.setHidden(true)
        self.tableView.setHidden(false)
    }

    private func updateForNotEnabledState() {
        D3Spinner().stopSpinner(loadingImage)
        self.loadingGroup.setHidden(true)
        self.notEnabledLabel.setHidden(false)
        self.tableView.setHidden(true)
    }
}


