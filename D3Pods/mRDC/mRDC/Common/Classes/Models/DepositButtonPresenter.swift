//
//  DepositButtonPresenter.swift
//  mRDC
//
//  Created by Branden Smith on 7/17/19.
//

import Foundation
import Localization
import UIKit
import UITableViewPresentation

struct DepositButtonPresenter: UITableViewPresentable {
    private let l10nProvider: L10nProvider

    init(l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
    }

    func configure(cell: DepositButtonCell, at indexPath: IndexPath) {
        cell.stackedMenuView.titleLabel.text = l10nProvider.localize("dashboard.widget.deposit.btn.launch")
        cell.stackedMenuView.imageView.image = UIImage(named: "RdcIcon", in: RDCBundle.bundle, compatibleWith: nil)
        cell.accessibilityLabel = l10nProvider.localize("dashboard.widget.deposit.btn.launch.altText")
        cell.accessibilityTraits = [.button]
    }
}

extension DepositButtonPresenter: Equatable {
    static func ==(_ lhs: DepositButtonPresenter, _ rhs: DepositButtonPresenter) -> Bool {
        return true
    }
}

extension DepositButtonPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
