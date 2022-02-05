//
//  CardPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation

protocol CardPresenterDelegate: class {
    func toggleChanged(forSender sender: UISwitch, inPresenter presenter: CardPresenter)
}

class CardPresenter: UITableViewPresentable {
    var card: Card

    // swiftlint:disable:next weak_delegate
    weak var delegate: CardPresenterDelegate!
    weak var cell: CardCell!

    var cellReuseIdentifier: String {
        return "CardCell"
    }

    init(card: Card, delegate: CardPresenterDelegate) {
        self.card = card
        self.delegate = delegate
    }

    func configure(cell: CardCell, at indexPath: IndexPath) {
        self.cell = cell
        cell.activityIndicator.isHidden = true
        cell.maskedAccountNumberLabel.text = card.maskedCardNumber
        cell.cardHolderLabel.text = card.signerName
        cell.activeLabel.text = "Active"
        cell.activateCardSwitch.isOn = card.activated
        cell.activateCardSwitch.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
    }

    func startLoadingAnimation() {
        cell?.activateCardSwitch.isHidden = true
        cell?.activityIndicator.isHidden = false
        cell?.activityIndicator.startAnimating()
    }

    func stopLoadingAnimation() {
        cell?.activateCardSwitch.isHidden = false
        cell?.activityIndicator.stopAnimating()
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        delegate?.toggleChanged(forSender: sender, inPresenter: self)
    }
}

extension CardPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension CardPresenter: Equatable {
    static func ==(lhs: CardPresenter, rhs: CardPresenter) -> Bool {
        guard lhs.card == rhs.card else { return false }

        return true
    }
}
