//
//  RDCSectionHeaderPresenter.swift
//  mRDC
//
//  Created by Chris Carranza on 11/14/18.
//

import Foundation
import UITableViewPresentation

final class RDCSectionHeaderPresenter: UITableViewHeaderFooterPresentable {
    private let title: String
    private let separatorColor: UIColor?
    private let backgroundColor: UIColor?
    private let accessibilityLabel: String?
    
    init(title: String, accessibilityLabel: String?, backgroundColor: UIColor?, separatorColor: UIColor?) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
    }
    
    func configure(view: RDCSectionHeaderView, for section: Int) {
        view.titleLabel.text = title
        view.titleLabel.accessibilityLabel = accessibilityLabel
        view.backgroundColor = backgroundColor
        view.topDividerView.backgroundColor = separatorColor
        view.bottomDividerView.backgroundColor = separatorColor
    }
    
    static func == (lhs: RDCSectionHeaderPresenter, rhs: RDCSectionHeaderPresenter) -> Bool {
        return lhs.title == rhs.title
    }
}

extension RDCSectionHeaderPresenter: UITableViewHeaderFooterNibRegistrable {
    var nib: UINib {
        return RDCBundle.nib(name: viewReuseIdentifier)
    }
}
