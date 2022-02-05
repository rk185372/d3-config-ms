//
//  LogoutMenuViewController.swift
//  LogoutViewController
//
//  Created by Chris Carranza on 9/12/18.
//

import UIKit
import Utilities
import ComponentKit
import Localization

final class LogoutMenuViewController: UIViewControllerComponent {
    
    init(config: ComponentConfig) {
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .loggedOut, object: nil)
    }
}
