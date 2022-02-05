//
//  AccountTypePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/21/19.
//

import D3Accounts
import ComponentKit
import Foundation
import Localization
import UIKit
import ViewPresentable

protocol AccountTypePresenterDelegate: class {
    func accountTypePresenter(_ presenter: AccountTypePresenter, selectedItemChangedTo selectedItem: RawAccountProduct)
}

final class AccountTypePresenter: NSObject, ViewPresentable {
    private let componentStyleProvider: ComponentStyleProvider
    private let l10nProvider: L10nProvider
    private let style: SelectionBoxStyleKey

    private var accountTypeHolder: AccountTypeHolder
    private weak var view: SelectionBox?
    private weak var delegate: AccountTypePresenterDelegate?

    init(accountTypeHolder: AccountTypeHolder,
         componentStyleProvider: ComponentStyleProvider,
         l10nProvider: L10nProvider,
         style: SelectionBoxStyleKey,
         delegate: AccountTypePresenterDelegate? = nil) {
        self.accountTypeHolder = accountTypeHolder
        self.componentStyleProvider = componentStyleProvider
        self.l10nProvider = l10nProvider
        self.style = style
        self.delegate = delegate
    }

    func configure(view: SelectionBox) {
        self.view = view
        view.titleLabel.text = l10nProvider.localize("accounts.form.type")
        view.valueLabel.text = "This is the Value"

        view.valueLabel.text = accountTypeHolder.selectedItem?.name
        view.valueLabel.gestureRecognizers?.forEach { view.valueLabel.removeGestureRecognizer($0) }
        view.valueLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(valueLabelTouched(_:)))
        )

        view.pickerView.dataSource = self
        view.pickerView.delegate = self
        view.pickerView.isHidden = true

        let componentStyle: SelectionBoxStyle = componentStyleProvider[style.rawValue]
        componentStyle.style(component: view)
    }

    func createView() -> SelectionBox {
        return ComponentKitBundle
            .bundle
            .loadNibNamed("SelectionBox", owner: nil, options: [:])?
            .first as! SelectionBox
    }

    private func updateValueLabel() {
        view?.valueLabel.text = accountTypeHolder.selectedItem?.name
    }

    @objc private func valueLabelTouched(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view?.pickerView.isHidden.toggle()
        })
    }
}

extension AccountTypePresenter: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accountTypeHolder.choices.count
    }
}

extension AccountTypePresenter: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = accountTypeHolder.choices[row]

        accountTypeHolder.selectedItem = selectedItem
        updateValueLabel()
        delegate?.accountTypePresenter(self, selectedItemChangedTo: selectedItem)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accountTypeHolder.choices[row].name
    }
}
