//
//  EDocsPromptAccountCell.swift
//  EDocs
//
//  Created by Branden Smith on 12/7/17.
//

import Foundation
import UIKit
import M13Checkbox
import ComponentKit
import RxSwift

final class EDocsPromptAccountCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var accountNameLabel: UILabelComponent!
    @IBOutlet weak var accountNumberLabel: UILabelComponent!
    @IBOutlet weak var checkbox: M13Checkbox!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    /// Since we can't turn mutable property into a get-only property via override,
    /// we'll want to make our own getter and setter where a newValue can still be set but would return only what we need
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.none
        }
        set {
            _ = newValue
        }
    }
}
