//
//  FailedToLoadPresenter.swift
//  mRDC
//
//  Created by Branden Smith on 7/19/19.
//

import Foundation
import UIKit
import UITableViewPresentation

final class FailedToLoadPresenter: UITableViewPresentable {
    private let infoText: String
    private let selector: Selector
    private let event: UIControl.Event

    private weak var target: AnyObject?

    init(infoText: String, target: AnyObject, selector: Selector, event: UIControl.Event) {
        self.infoText = infoText
        self.target = target
        self.selector = selector
        self.event = event
    }

    func configure(cell: FailedToLoadCell, at indexPath: IndexPath) {
        cell.noItemsView.infoLabel.text = infoText

        if let target = target {
            cell.noItemsView.tryAgainButton.addTarget(target, action: selector, for: event)
        }
    }
}

extension FailedToLoadPresenter: Equatable {
    static func ==(_ lhs: FailedToLoadPresenter, _ rhs: FailedToLoadPresenter) -> Bool {
        return lhs.infoText == rhs.infoText
            && lhs.selector == rhs.selector
            && lhs.event == rhs.event
    }
}

extension FailedToLoadPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
