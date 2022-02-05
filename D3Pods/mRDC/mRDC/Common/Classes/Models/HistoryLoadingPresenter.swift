//
//  HistoryLoadingPresenter.swift
//  mRDC
//
//  Created by Branden Smith on 7/18/19.
//

import Foundation
import UIKit
import UITableViewPresentation

struct HistoryLoadingPresenter: UITableViewPresentable {
    func configure(cell: HistoryLoadingCell, at indexPath: IndexPath) {
        cell.activityIndicator.startAnimating()
    }
}

extension HistoryLoadingPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
