//
//  OpenANewAccountPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/10/19.
//

import ComponentKit
import Foundation
import UITableViewPresentation

protocol OpenANewAccountPresenterDelegate: class {
    func openAccountButtonTouched(_ button: UIButtonComponent, inPresenter presenter: OpenANewAccountPresenter)
}

final class OpenANewAccountPresenter: UITableViewPresentable {

    weak var delegate: OpenANewAccountPresenterDelegate?

    init(delegate: OpenANewAccountPresenterDelegate) {
        self.delegate = delegate
    }

    func configure(cell: OpenANewAccountCell, at indexPath: IndexPath) {
        // labels and button text configured in nib.
        cell.openAccountButton.removeTarget(nil, action: #selector(openAccountButtonTouched(_:)), for: .allEvents)
        cell.openAccountButton.addTarget(self, action: #selector(openAccountButtonTouched(_:)), for: .touchUpInside)
    }

    @objc private func openAccountButtonTouched(_ sender: UIButtonComponent) {
        delegate?.openAccountButtonTouched(sender, inPresenter: self)
    }
}

extension OpenANewAccountPresenter: Equatable {
    static func ==(_ lhs: OpenANewAccountPresenter, _ rhs: OpenANewAccountPresenter) -> Bool {
        return true
    }
}

extension OpenANewAccountPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
