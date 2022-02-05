//
//  ButtonPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/6/18.
//

import Foundation
import UITableViewPresentation
import ComponentKit

public final class ButtonPresenter: UITableViewPresentable {
    private let buttonTitle: String
    private let style: ButtonStyleKey

    private var clickListener: ((UIButtonComponent) -> Void)?

    public init(buttonTitle: String,
                style: ButtonStyleKey,
                clickListener: ((UIButtonComponent) -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.style = style
        self.clickListener = clickListener
    }

    public func configure(cell: ButtonCell, at indexPath: IndexPath) {
        cell.button.setTitle(buttonTitle, for: .normal)
        cell.button.removeTarget(nil, action: nil, for: .allEvents)
        cell.button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        cell.button.configureComponent(withStyle: style)
    }

    @objc private func buttonTouched(_ sender: UIButtonComponent) {
        clickListener?(sender)
    }
}

extension ButtonPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: PresenterKitBundle.bundle)
    }
}

extension ButtonPresenter: Equatable {
    public static func ==(lhs: ButtonPresenter, rhs: ButtonPresenter) -> Bool {
        guard lhs.buttonTitle == rhs.buttonTitle else { return false }

        return true
    }
}
