//
//  CurrencyEntryTextField.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/27/18.
//

import Foundation
import UIKit
import ComponentKit

final class RDCCurrencyEntryTextField: UITextFieldComponent {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action != #selector(copy(_:)),
        action != #selector(selectAll(_:)),
        action != #selector(paste(_:)) else {
            return false
        }
        
        return true
    }
}
