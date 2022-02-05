//
//  StartCheckNumberPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import Foundation
import UIKit

final class StartCheckNumberPresenter: StopRangeOfPaymentsPresenter {
    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.textField.delegate = self
        cell.titleLabel.text = "Starting Check #"
        cell.textField.keyboardType = .numberPad
    }
}

extension StartCheckNumberPresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        stoppedRange.checkNumberFrom = textField.text ?? ""
    }
}
