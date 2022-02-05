//
//  BuildInfoItemPresenter.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 12/17/18.
//

import Foundation
import UIKit
import UITableViewPresentation

struct BuildInfoItemPresenter: UITableViewPresentable {
    private let infoItem: BuildInfoItem

    init(infoItem: BuildInfoItem) {
        self.infoItem = infoItem
    }

    func configure(cell: BuildInfoCell, at indexPath: IndexPath) {
        cell.keyLabel.text = infoItem.key
        cell.valueLabel.text = infoItem.value
    }

    func toString() -> String {
        return "\(infoItem.key): \(infoItem.value)"
    }
}

extension BuildInfoItemPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: BuildInfoScreenBundle.bundle)
    }
}

extension BuildInfoItemPresenter: Equatable {
    static func ==(_ lhs: BuildInfoItemPresenter, _ rhs: BuildInfoItemPresenter) -> Bool {
        return lhs.infoItem == rhs.infoItem
    }
}
