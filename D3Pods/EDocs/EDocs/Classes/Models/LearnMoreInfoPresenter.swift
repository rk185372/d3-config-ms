//
//  LearnMoreInfoPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 12/16/19.
//

import Foundation
import UIKit
import UITableViewPresentation

struct LearnMoreInfoPresenter: UITableViewPresentable {
    private let titleText: String
    private let descriptionText: String

    init(titleText: String, descriptionText: String) {
        self.titleText = titleText
        self.descriptionText = descriptionText
    }

    func configure(cell: LearnMoreInfoCell, at indexPath: IndexPath) {
        cell.titleLabel.text = titleText
        cell.descriptionLabel.text = descriptionText
    }
}

extension LearnMoreInfoPresenter: Equatable {
    static func ==(_ lhs: LearnMoreInfoPresenter, _ rhs: LearnMoreInfoPresenter) -> Bool {
        return lhs.titleText == rhs.titleText
            && lhs.descriptionText == rhs.descriptionText
    }
}

extension LearnMoreInfoPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
