//
//  SessionExpirationWarningVCFactory.swift
//  D3 Banking
//
//  Created by Branden Smith on 9/10/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import ComponentKit
import Foundation
import Localization
import UIKit

final class SessionExpirationWarningVCFactory {
    private let l10nProvider: L10nProvider
    private let styleProvider: ComponentStyleProvider

    init(l10nProvider: L10nProvider, styleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.styleProvider = styleProvider
    }

    func create(remainingTime: Int,
                delegate: SessionExpirationWarningViewControllerDelegate? = nil) -> SessionExpirationWarningViewController {
        return SessionExpirationWarningViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: styleProvider,
            remainingTime: remainingTime,
            delegate: delegate
        )
    }
}
