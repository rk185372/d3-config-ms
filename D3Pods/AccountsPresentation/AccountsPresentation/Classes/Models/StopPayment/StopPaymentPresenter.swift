//
//  StopPaymentPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import D3Accounts
import Foundation
import UITableViewPresentation

class StopPaymentPresenter: NSObject, UITableViewPresentable {

    let stoppedPayment: StoppedPayment
    private var textField: UITextField!

    init(stoppedPayment: StoppedPayment) {
        self.stoppedPayment = stoppedPayment
    }

    func configure(cell: TextInputCell, at indexPath: IndexPath) {
        textField = cell.textField
        // Add a done button to the decimal pad so that the user can dismiss the keyboard.
        let doneToolbar = UIToolbar(frame: .zero)
        doneToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTouched(_:)))
        ]
        doneToolbar.sizeToFit()

        cell.textField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTouched(_ sender: UIBarButtonItem) {
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
}

extension StopPaymentPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: "TextInputCell", bundle: AccountsPresentationBundle.bundle)
    }
}
