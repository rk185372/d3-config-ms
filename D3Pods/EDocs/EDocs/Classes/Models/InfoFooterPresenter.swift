//
//  InfoFooterPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 1/3/20.
//

import Foundation
import UIKit
import UITableViewPresentation

struct InfoFooterPresenter: UITableViewHeaderFooterPresentable {

    private let infoText: String

    init(infoText: String) {
        self.infoText = infoText
    }

    func configure(view: InfoFooter, for section: Int) {
        view.infoLabel.text = infoText
    }
}

extension InfoFooterPresenter: Equatable {
    static func ==(_ lhs: InfoFooterPresenter, _ rhs: InfoFooterPresenter) -> Bool {
        return lhs.infoText == rhs.infoText
    }
}

extension InfoFooterPresenter: UITableViewHeaderFooterNibRegistrable {
    var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
