//
//  UIContentSizeCategory+Accessibility.swift
//  Utilities
//
//  Created by Branden Smith on 3/7/18.
//

import Foundation

public extension UIContentSizeCategory {
    var isAccessibilitySize: Bool {
        if #available(iOS 11, *) {
            return isAccessibilityCategory
        } else {
            return self == .accessibilityMedium
                || self == .accessibilityLarge
                || self == .accessibilityExtraLarge
                || self == .accessibilityExtraExtraLarge
                || self == .accessibilityExtraExtraExtraLarge
        }
    }
}
