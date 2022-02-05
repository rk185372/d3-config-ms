//
//  AccountNamePresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/24/19.
//

import ComponentKit
import Foundation
import Localization
import ViewPresentable

protocol AccountNamePresenterDelegate: class {
    func accountNamePresenter(_ presenter: AccountNamePresenter, didUpdateNameTo name: String)
}

final class AccountNamePresenter: ViewPresentable {
    private let styleKey: TitledTextFieldStyleKey
    private let componentStyleProvider: ComponentStyleProvider
    private let l10nProvider: L10nProvider

    private weak var delegate: AccountNamePresenterDelegate?

    public init(styleKey: TitledTextFieldStyleKey,
                componentStyleProvider: ComponentStyleProvider,
                l10nProvider: L10nProvider,
                delegate: AccountNamePresenterDelegate? = nil) {
        self.styleKey = styleKey
        self.componentStyleProvider = componentStyleProvider
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }

    func configure(view: TitledTextFieldComponent) {
        view.titleLabel.text = l10nProvider.localize("accounts.form.name")

        view.textField.removeTarget(self, action: #selector(textFieldValueChanged(_:)), for: .allEvents)
        view.textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)

        let style: TitledTextFieldStyle = componentStyleProvider[styleKey.rawValue]
        style.style(component: view)
    }

    func createView() -> TitledTextFieldComponent {
        return ComponentKitBundle
            .bundle
            .loadNibNamed("TitledTextFieldComponent", owner: nil, options: [:])?
            .first as! TitledTextFieldComponent
    }

    @objc private func textFieldValueChanged(_ sender: UITextField) {
        if let newValue = sender.text {
            delegate?.accountNamePresenter(self, didUpdateNameTo: newValue)
        }
    }
}

extension AccountNamePresenter: Equatable {
    static func ==(_ lhs: AccountNamePresenter, _ rhs: AccountNamePresenter) -> Bool {
        return true
    }
}
