//
//  NoHistoryPresenter.swift
//  mRDC
//
//  Created by Branden Smith on 7/18/19.
//

import Foundation
import UITableViewPresentation

struct NoHistoryPresenter: UITableViewPresentable {
    func configure(cell: NoHistoryCell, at indexPath: IndexPath) {}
}

extension NoHistoryPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
