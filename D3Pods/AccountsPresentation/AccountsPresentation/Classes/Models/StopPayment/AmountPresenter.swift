//
//  AmountPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation

final class AmountPresenter: StopPaymentPresenter {
    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.titleLabel.text = "Amount"
        cell.textField.delegate = self
        cell.textField.keyboardType = .decimalPad
    }
}

extension AmountPresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let amount = Double(textField.text!) else { return }
        stoppedPayment.amount = amount
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // If the text field's text already contains a decimal, don't add
        // another one.
        if textField.text?.contains(".") ?? true && string == "." {
            return false
        }

        // If there are already two characters after the decimal, we do not let them add any more.
        if let index = textField.text?.firstIndex(of: ".")?.encodedOffset, range.location > index + 2 {
            return false
        }

        return true
    }
}
