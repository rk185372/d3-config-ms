//
//  UIStackView+Init.swift
//  Utilities-iOS
//
//  Created by Pablo Pellegrino on 17/09/2021.
//

import Foundation

extension UIStackView {
    public convenience init(arrangedSubviews: [UIView] = [],
                            axis: NSLayoutConstraint.Axis,
                            alignment: UIStackView.Alignment = .fill,
                            distribution: UIStackView.Distribution = .fill,
                            spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
}
