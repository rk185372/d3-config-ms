//
//  ButtonViewPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/25/19.
//

import ComponentKit
import Foundation
import ViewPresentable

final class ButtonViewPresenter: ViewPresentable {
    private let styleKey: ButtonStyleKey
    private let componentStyleProvider: ComponentStyleProvider
    private let buttonTitle: String

    private var onSelect: ((UIButtonComponent) -> Void)?

    init(styleKey: ButtonStyleKey,
         componentStyleProvider: ComponentStyleProvider,
         buttonTitle: String,
         onSelect: ((UIButtonComponent) -> Void)? = nil) {
        self.styleKey = styleKey
        self.componentStyleProvider = componentStyleProvider
        self.buttonTitle = buttonTitle
        self.onSelect = onSelect
    }

    func createView() -> ButtonView {
        return AccountsPresentationBundle
            .bundle
            .loadNibNamed("ButtonView", owner: nil, options: [:])?
            .first as! ButtonView
    }

    func configure(view: ButtonView) {
        view.button.setTitle(buttonTitle, for: .normal)
        view.button.removeTarget(nil, action: #selector(buttonTouched(_:)), for: .allEvents)
        view.button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        view.button.configureComponent(withStyle: styleKey)
    }

    @objc private func buttonTouched(_ sender: UIButtonComponent) {
        onSelect?(sender)
    }
}

extension ButtonViewPresenter: Equatable {
    static func ==(_ lhs: ButtonViewPresenter, _ rhs: ButtonViewPresenter) -> Bool {
        return lhs.styleKey == rhs.styleKey
            && lhs.buttonTitle == rhs.buttonTitle
    }
}
