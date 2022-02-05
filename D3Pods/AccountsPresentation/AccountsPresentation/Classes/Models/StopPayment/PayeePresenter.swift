//
//  PayeePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation

final class PayeePresenter: StopPaymentPresenter {

    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.titleLabel.text = "Payee"
        cell.textField.delegate = self
    }
}

extension PayeePresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        stoppedPayment.payee = textField.text ?? ""
    }
}
