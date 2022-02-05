//
//  UI+Rx.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/17/18.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UILabel {
    /// Bindable sink for `font` property
    public var font: Binder<UIFont?> {
        return Binder(self.base) { label, font in
            label.font = font
        }
    }
}

extension Reactive where Base: UITextField {
    /// Bindable sink for `font` property
    public var font: Binder<UIFont?> {
        return Binder(self.base) { label, font in
            label.font = font
        }
    }
}

extension Reactive where Base: UITextView {
    /// Bindable sink for `font` property
    public var font: Binder<UIFont?> {
        return Binder(self.base) { label, font in
            label.font = font
        }
    }
}
