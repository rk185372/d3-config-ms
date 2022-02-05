//
//  AccountBalancePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/24/19.
//

import ComponentKit
import Foundation
import Localization
import ViewPresentable

protocol AccountBalancePresenterDelegate: class {
    func accountBalancePresenter(_ presenter: AccountBalancePresenter, balanceChangedTo balance: Decimal)
}

final class AccountBalancePresenter: NSObject, ViewPresentable {
    private let styleKey: TitledTextFieldStyleKey
    private let componentStyleProvider: ComponentStyleProvider
    private let l10nProvider: L10nProvider

    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.roundingMode = .down
        return f
    }()

    private weak var delegate: AccountBalancePresenterDelegate?

    init(styleKey: TitledTextFieldStyleKey,
         componentStyleProvider: ComponentStyleProvider,
         l10nProvider: L10nProvider,
         delegate: AccountBalancePresenterDelegate? = nil) {
        self.styleKey = styleKey
        self.componentStyleProvider = componentStyleProvider
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }

    func createView() -> TitledTextFieldComponent {
        return ComponentKitBundle
            .bundle
            .loadNibNamed("TitledTextFieldComponent", owner: nil, options: [:])?
            .first as! TitledTextFieldComponent
    }

    func configure(view: TitledTextFieldComponent) {
        view.titleLabel.text = l10nProvider.localize("accounts.form.balance")
        view.textField.textAlignment = .right
        view.textField.keyboardType = .numberPad
        view.textField.delegate = self
        view.textField.text = NumberFormatter
            .currencyFormatter()
            .string(from: (Decimal(0) as NSDecimalNumber))

        let style: TitledTextFieldStyle = componentStyleProvider[styleKey.rawValue]
        style.style(component: view)
    }

    @objc private func textChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        let sanitizedString = String(text.dropFirst().replacingOccurrences(of: ",", with: ""))

        guard let number = Decimal(string: sanitizedString) else { return }

        delegate?.accountBalancePresenter(self, balanceChangedTo: number)
    }
}

extension AccountBalancePresenter: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //check delete
        guard let currentText = textField.text,
            let number = formatter.number(from: currentText) else {
                return false
        }

        var amount: Double

        if let typedDigit = Double(string) {
            amount = (Double(truncating: number.decimalValue as NSDecimalNumber) * 10) + (typedDigit / 100)
        } else {
            //delete
            amount = Double(truncating: number.decimalValue as NSDecimalNumber) / 10
        }

        textField.text = formatter.string(from: NSNumber(value: amount))
        self.textChanged(textField)
        return false
    }
}
