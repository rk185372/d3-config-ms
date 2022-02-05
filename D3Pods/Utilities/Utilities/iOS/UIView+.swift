//
//  UIView+.swift
//  Utilities
//
//  Created by Andrew Watt on 7/31/18.
//

import UIKit

public extension UIView {
    /// True if this view is attached to the view hierarchy
    var isVisible: Bool {
        return self.window != nil
    }
    
    /// All descendent subviews lazily concatenated into a single sequence.
    var descendantViews: AnySequence<UIView> {
        let children = AnySequence(subviews.lazy)
        let descendants = AnySequence(subviews.lazy.flatMap { $0.descendantViews })
        return AnySequence([children, descendants].joined())
    }
    
    func firstSubviewOfKind<T: UIView>() -> T? {
        for view in subviews {
            if let t = view as? T {
                return t
            }
            if let t: T = view.firstSubviewOfKind() {
                return t
            }
        }
        return nil
    }
}
