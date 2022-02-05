//
//  UIStackView+SubviewRemoval.swift
//  Utilities
//
//  Created by Branden Smith on 3/20/18.
//

import Foundation
import UIKit

extension UIStackView {
    /// Removes all of the views in views from the stack view.
    public func removeAllViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}
