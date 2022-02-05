//
//  EDocsAccountSelectionHeaderPresentable.swift
//  EDocs
//
//  Created by Branden Smith on 12/12/19.
//

import Foundation
import UITableViewPresentation

struct EDocsAccountSelectionHeaderPresentable: UITableViewHeaderFooterPresentable {
    private let titleText: String
    private let subtitleText: String

    var viewReuseIdentifier: String {
        return "EDocsAccountSelectionHeader"
    }

    init(title: String, subtitle: String) {
        self.titleText = title
        self.subtitleText = subtitle
    }

    func configure(view: EDocsAccountSelectionHeader, for section: Int) {
        view.titleLabel.text = titleText
        view.descriptionLabel.text = subtitleText
    }
}

extension EDocsAccountSelectionHeaderPresentable: UITableViewHeaderFooterNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}

extension EDocsAccountSelectionHeaderPresentable: Equatable {
    public static func ==(lhs: EDocsAccountSelectionHeaderPresentable,
                          rhs: EDocsAccountSelectionHeaderPresentable) -> Bool {
        return lhs.titleText == rhs.titleText
            && lhs.subtitleText == rhs.subtitleText
    }
}
