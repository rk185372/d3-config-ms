//
//  DisclosureButtonFooterPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 12/13/19.
//

import ComponentKit
import Foundation
import UITableViewPresentation

protocol DisclosureButtonFooterDelegate: class {
    func disclosureButtonTouched(_ sender: UIButtonComponent)
}

final class DisclosureButtonFooterPresenter: UITableViewHeaderFooterPresentable {
    private let disclosureButtonTitle: String

    private weak var delegate: DisclosureButtonFooterDelegate?

    var viewReuseIdentifier: String {
        return "DisclosureButtonFooter"
    }

    init(disclosureButtonTitle: String, delegate: DisclosureButtonFooterDelegate) {
        self.disclosureButtonTitle = disclosureButtonTitle
        self.delegate = delegate
    }

    func configure(view: DisclosureButtonFooter, for section: Int) {
        UIView.performWithoutAnimation {
            view.disclosureButton.setTitle(disclosureButtonTitle, for: .normal)
            view.disclosureButton.layoutIfNeeded()
        }
        view.disclosureButton.addTarget(self, action: #selector(disclosureButtonTouched(_:)), for: .touchUpInside)
    }

    @objc private func disclosureButtonTouched(_ sender: UIButtonComponent) {
        delegate?.disclosureButtonTouched(sender)
    }
}

extension DisclosureButtonFooterPresenter: Equatable {
    static func ==(_ lhs: DisclosureButtonFooterPresenter, _ rhs: DisclosureButtonFooterPresenter) -> Bool {
        return lhs.disclosureButtonTitle == rhs.disclosureButtonTitle
    }
}

extension DisclosureButtonFooterPresenter: UITableViewHeaderFooterNibRegistrable {
    var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
