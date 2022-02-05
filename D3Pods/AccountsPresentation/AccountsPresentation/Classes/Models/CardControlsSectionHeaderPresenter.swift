//
//  CardControlsSectionHeaderPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import Foundation
import UITableViewPresentation

struct CardControlsSectionHeaderPresenter: UITableViewHeaderFooterPresentable, Equatable {

    let title: String

    init(title: String) {
        self.title = title
    }

    func configure(view: CardControlsSectionHeader, for section: Int) {
        view.titleLabel.text = title
    }
}

extension CardControlsSectionHeaderPresenter: UITableViewHeaderFooterNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
