//
//  DepositDelayInfoPresenter.swift
//  mRDC
//
//  Created by Branden Smith on 7/17/19.
//

import Foundation
import UITableViewPresentation

struct DepositDelayInfoPresenter: UITableViewPresentable {
    func configure(cell: DepositDelayInfoCell, at indexPath: IndexPath) {}
}

extension DepositDelayInfoPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
