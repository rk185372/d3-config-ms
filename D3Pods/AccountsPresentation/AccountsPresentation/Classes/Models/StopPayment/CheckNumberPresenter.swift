//
//  CheckNumberPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation

final class CheckNumberPresenter: StopPaymentPresenter {

    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.titleLabel.text = "Check #"
        cell.textField.delegate = self
        cell.textField.keyboardType = .numberPad
    }
}

extension CheckNumberPresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        stoppedPayment.checkNumber = textField.text ?? ""
    }
}
