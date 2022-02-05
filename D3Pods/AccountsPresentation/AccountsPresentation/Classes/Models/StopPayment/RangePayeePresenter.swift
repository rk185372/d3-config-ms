//
//  RangePayeePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

final class RangePayeePresenter: StopRangeOfPaymentsPresenter {

    override func configure(cell: TextInputCell, at indexPath: IndexPath) {
        super.configure(cell: cell, at: indexPath)
        cell.titleLabel.text = "Payee"
        cell.textField.delegate = self
    }
}

extension RangePayeePresenter: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        stoppedRange.payee = textField.text ?? ""
    }
}
