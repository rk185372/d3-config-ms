//
//  SwitchPresenter.swift
//  PresenterKit
//
//  Created by Branden Smith on 10/25/19.
//

import ComponentKit
import Foundation
import UITableViewPresentation

public final class SwitchPresenter: UITableViewPresentable {
    private let title: String
    private let toggleListener: (UISwitchComponent) -> Void

    private var switchState: Bool

    public init(title: String, initialState: Bool = true, toggleListener: @escaping (UISwitchComponent) -> Void) {
        self.title = title
        self.switchState = initialState
        self.toggleListener = toggleListener
    }

    public func configure(cell: SwitchCell, at indexPath: IndexPath) {
        cell.titleLabel.text = title
        cell.uiSwitch.isOn = switchState

        cell.uiSwitch.removeTarget(self, action: nil, for: .allEvents)
        cell.uiSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }

    @objc private func switchToggled(_ sender: UISwitchComponent) {
        switchState = sender.isOn
        toggleListener(sender)
    }
}

extension SwitchPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: PresenterKitBundle.bundle)
    }
}

extension SwitchPresenter: Equatable {
    public static func ==(_ lhs: SwitchPresenter, _ rhs: SwitchPresenter) -> Bool {
        return lhs.title == rhs.title
    }
}
