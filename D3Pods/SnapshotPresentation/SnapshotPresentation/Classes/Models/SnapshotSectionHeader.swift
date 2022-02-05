//
//  SnapshotSectionHeader.swift
//  Snapshot
//
//  Created by Andrew Watt on 10/5/18.
//

import UIKit
import UITableViewPresentation

struct SnapshotSectionHeader: UITableViewHeaderFooterPresentable {
    let title: String
    
    func configure(view: SnapshotSectionHeaderView, for section: Int) {
        view.sectionHeaderView.titleLabel.text = title
    }
}

extension SnapshotSectionHeader: UITableViewHeaderFooterNibRegistrable {
    var nib: UINib {
        return SnapshotPresentationBundle.nib(name: viewReuseIdentifier)
    }
}
