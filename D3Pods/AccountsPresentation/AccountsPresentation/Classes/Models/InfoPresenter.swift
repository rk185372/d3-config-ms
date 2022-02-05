//
//  InfoPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import Foundation
import UITableViewPresentation
import Transactions

struct InfoPresenter: UITableViewPresentable, Equatable {
    let info: String

    init(info: String) {
        self.info = info
    }

    func configure(cell: InfoCell, at indexPath: IndexPath) {
        cell.infoLabel.text = info
    }
}

extension InfoPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
