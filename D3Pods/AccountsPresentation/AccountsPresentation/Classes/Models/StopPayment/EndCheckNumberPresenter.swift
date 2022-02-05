//
//  EndCheckNumberPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import Foundation
import UIKit

final class EndCheckNumberPresenter: StopRangeOfPaymentsPresenter {
    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.textField.delegate = self
        cell.titleLabel.text = "Ending Check #"
        cell.textField.keyboardType = .numberPad
    }
}

extension EndCheckNumberPresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        stoppedRange.checkNumberTo = textField.text ?? ""
    }
}
