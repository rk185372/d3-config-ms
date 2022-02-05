//
//  TableSectionHeader.swift
//  ComponentKit
//
//  Created by Jose Torres on 12/7/20.
//

import UIKit
import UITableViewPresentation

public struct TableSectionHeader: UITableViewHeaderFooterPresentable {
    let title: String

    public init(title: String) {
        self.title = title
    }

    public func configure(view: TableSectionHeaderView, for section: Int) {
        view.sectionHeaderView.titleLabel.text = title
    }
}

extension TableSectionHeader: UITableViewHeaderFooterNibRegistrable {
    public var nib: UINib {
        return ComponentKitBundle.nib(name: viewReuseIdentifier)
    }
}
