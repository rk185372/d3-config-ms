//
//  AuthBusinessDialogControllerFactory.swift
//  Authentication
//
//  Created by Jose Torres on 3/15/21.
//

import Foundation
import ComponentKit
import Localization

public final class AuthDialogControllerFactory {

    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }

    public func create(type: AuthDialogType,
                       delegate: AuthDialogViewControllerDelegate? = nil) -> UIViewController {
        switch type {
        case .toolTip:
            let controller = AuthBusinessTooltipViewController(l10nProvider: l10nProvider,
                                                               componentStyleProvider: componentStyleProvider)
            return controller
        case .forgotUsernamePassword(let url):
            let controller = AuthBusinessForgotViewController(l10nProvider: l10nProvider,
                                                              componentStyleProvider: componentStyleProvider,
                                                              url: url)
            controller.delegate = delegate
            return controller
        case .enrollment(let url):
            let controller = AuthBusinessEnrollmentViewController(l10nProvider: l10nProvider,
                                                                  componentStyleProvider: componentStyleProvider,
                                                                  url: url)
            controller.delegate = delegate
            return controller
        }
    }
}
