//
//  TextFieldManager.swift
//  Utilities
//
//  Created by Branden Smith on 7/26/18.
//

import Foundation
import UIKit

public protocol TextFieldManagerDelegate: class {
    func editingEnded(forTextField textField: UITextField, managedBy manager: TextFieldManager)
}

public final class TextFieldManager: NSObject, UITextFieldDelegate {

    public weak var delegate: TextFieldManagerDelegate?

    private var textLengthLimit: Int = 256

    public init(delegate: TextFieldManagerDelegate) {
        super.init()
        self.delegate = delegate
    }

    public override init() {
        super.init()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.editingEnded(forTextField: textField, managedBy: self)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentTextLength = textField.text?.count ?? 0
        let newLength = currentTextLength + string.count - range.length

        return newLength <= textLengthLimit
    }
}
