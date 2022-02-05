//
//  AccountDetailsButtonPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/22/18.
//

import Foundation
import UIKit
import UITableViewPresentation

struct AccountDetailsButtonPresenter: UITableViewPresentable {
    let leftButtonConfig: AccountDetailsButtonConfig
    let rightButtonConfig: AccountDetailsButtonConfig?

    func configure(cell: TwoButtonCell, at indexPath: IndexPath) {
        cell.leftButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.rightButton.removeTarget(nil, action: nil, for: .allEvents)

        cell.leftButton.setTitle(leftButtonConfig.title, for: .normal)
        cell.leftButton.addTarget(
            leftButtonConfig.target,
            action: leftButtonConfig.action,
            for: leftButtonConfig.controlEvent
        )

        // The left button for this presenter should always be present, but, in the event that
        // the right button is not, we want to remove the right button area from the
        // cell so that the left button becomes centered. To do this, we are hiding the
        // divider view in the center and the right button view. We then adjust the priority
        // of the left button trailing constraint (to the superview) so that its priority is
        // higher than the left button view's trailing constraint to the divider view
        // (this only has a priority of 750). If the right button is present we configure
        // things so that the divider view shows, the right button view and button show,
        // and the left button view's trailing constraint to superview has a priority lower
        // than that of the left button view's trailing constraint to the divider view.
        if let rightButtonConfiguration = rightButtonConfig {
            cell.rightButtonView.isHidden = false
            cell.dividerView.isHidden = false
            cell.rightButton.isHidden = false

            cell.rightButton.setTitle(rightButtonConfiguration.title, for: .normal)
            cell.rightButton.addTarget(
                rightButtonConfiguration.target,
                action: rightButtonConfiguration.action,
                for: rightButtonConfiguration.controlEvent
            )
        } else {
            cell.rightButtonView.isHidden = true
            cell.dividerView.isHidden = true
            cell.rightButton.isHidden = true
        }
    }
}

extension AccountDetailsButtonPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension AccountDetailsButtonPresenter: Equatable {
    static func ==(lhs: AccountDetailsButtonPresenter, rhs: AccountDetailsButtonPresenter) -> Bool {
        return true
    }
}
