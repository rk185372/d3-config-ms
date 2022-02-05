//
//  AccountsTodayViewController.swift
//  D3 Today Extension
//
//  Created by Branden Smith on 2/19/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import Snapshot
import SnapshotService
import TodayExtension
import UITableViewPresentation

final class AccountsTodayViewController: TodayViewController {
    override func snapshotState(given snapshotValue: SnapshotViewModel.Value) -> SnapshotState {
        switch snapshotValue {
        case .none, .snapshot, .detail:
            return .loading
        case .error(let error):
            return .error(message: message(forError: error))
        case .widget(widget: let widget):
            guard !widget.accounts.isEmpty else {
                return .error(message: l10nProvider.localize("launchPage.snapshot.no-accounts"))
            }
            return .complete(
                model: UITableViewModel(
                    rows: (view.traitCollection.preferredContentSizeCategory.isAccessibilitySize)
                        ? widget.accounts.map({ ADAAccountPresenter(account: $0) })
                        : widget.accounts.map({ AccountPresenter(account: $0) })
                )
            )
        }
    }
}
