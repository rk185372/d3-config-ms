//
//  CustomNumberPad.swift
//  Utilities-iOS
//
//  Created by Branden Smith on 9/19/19.
//

import Foundation
import UIKit

public final class CustomNumberPad: UIView {
    public weak var target: UITextField?

    @IBAction func digitButtonTouched(_ sender: UIButton) {
        guard let textField = target else { return }
        guard let replacementRange = getReplacementRange(forTextField: textField) else { return }
        guard let buttonText = sender.titleLabel?.text else { return }
        guard Int(buttonText) != nil else { return }

        let shouldChangeText = textField.delegate?.textField?(
            textField,
            shouldChangeCharactersIn: replacementRange,
            replacementString: "\(buttonText)"
        )

        if shouldChangeText ?? true {
            textField.insertText("\(buttonText)")
        }
    }

    @IBAction func deleteButtonTouched(_ sender: UIButton) {
        guard let textField = target else { return }
        guard let replacementRange = getReplacementRange(forTextField: textField) else { return }

        let shouldChangeText = textField.delegate?.textField?(
            textField,
            shouldChangeCharactersIn: replacementRange,
            replacementString: ""
        )

        if shouldChangeText ?? true {
            target?.deleteBackward()
        }
    }

    @IBAction func doneButtonTouched(_ sender: UIButton) {
        guard let textField = target else { return }

        if textField.delegate?.textFieldShouldReturn?(textField) ?? true {
            textField.resignFirstResponder()
        }
    }
}

extension CustomNumberPad {
    private func getReplacementRange(forTextField textField: UITextField) -> NSRange? {
        guard let range = textField.selectedTextRange else { return nil }

        let startPositon = range.start
        let endPosition = range.end
        let location = textField.offset(from: textField.beginningOfDocument, to: range.end)
        let length = textField.offset(from: startPositon, to: endPosition)

        return NSRange(location: location, length: length)
    }
}
