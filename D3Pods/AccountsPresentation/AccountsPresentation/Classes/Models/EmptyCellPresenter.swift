//
//  EmptyCellPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/23/18.
//

import Foundation
import UITableViewPresentation

struct EmptyCellPresenter: UITableViewPresentable {

    func configure(cell: EmptyCell, at indexPath: IndexPath) {}
}

extension EmptyCellPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension EmptyCellPresenter: Equatable {
    static func ==(lhs: EmptyCellPresenter, rhs: EmptyCellPresenter) -> Bool {
        return true
    }
}
