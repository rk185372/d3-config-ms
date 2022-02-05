//
//  AccountDetailsTogglePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/22/18.
//

import Foundation
import UIKit
import UITableViewPresentation

struct AccountDetailsTogglePresenter: UITableViewPresentable {
    let toggleConfig: AccountDetailsButtonConfig

    func configure(cell: ToggleCell, at indexPath: IndexPath) {
        cell.uiSwitch.removeTarget(nil, action: nil, for: .allEvents)

        cell.label.text = toggleConfig.title
        cell.uiSwitch.isOn = toggleConfig.isOn
        cell.uiSwitch.addTarget(
            toggleConfig.target,
            action: toggleConfig.action,
            for: toggleConfig.controlEvent
        )
    }

}

extension AccountDetailsTogglePresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension AccountDetailsTogglePresenter: Equatable {
    static func ==(lhs: AccountDetailsTogglePresenter, rhs: AccountDetailsTogglePresenter) -> Bool {
        return true
    }
}
