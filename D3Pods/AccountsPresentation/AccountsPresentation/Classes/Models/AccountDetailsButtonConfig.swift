//
//  AccountDetailsButtonConfig.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/22/18.
//

import Foundation
import UIKit

struct AccountDetailsButtonConfig {
    let title: String
    let target: Any?
    let action: Selector
    let controlEvent: UIControl.Event
    let isOn: Bool

    init(title: String, target: Any?, action: Selector, controlEvent: UIControl.Event, isOn: Bool = false) {
        self.title = title
        self.target = target
        self.action = action
        self.controlEvent = controlEvent
        self.isOn = isOn
    }
}
