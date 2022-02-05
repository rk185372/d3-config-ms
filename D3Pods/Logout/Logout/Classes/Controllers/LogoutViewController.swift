//
//  LogoutViewController.swift
//  LogoutViewController
//
//  Created by Chris Carranza on 9/12/18.
//

import UIKit
import Utilities
import ComponentKit
import Localization
import RxSwift
import Session

public final class LogoutViewController: UIViewControllerComponent {
    
    @IBOutlet weak var backgroundImageView: UIImageViewComponent!
    
    public let logoutComplete: Completable
    
    public init(config: ComponentConfig,
                logoutService: LogoutService,
                sessionService: SessionService) {
        
        logoutComplete = logoutService
            .logout()
            .ignoreError()
            .andThen(sessionService.clearSession())
        
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: LogoutBundle.bundle
        )
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage(named: "Background")
    }
}
