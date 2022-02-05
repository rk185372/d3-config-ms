//
//  UpgradeViewController.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/10/18.
//

import UIKit
import AppConfiguration
import ComponentKit
import Localization
import Utilities

final class UpgradeViewController: UIViewControllerComponent {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var updateButton: UIButtonComponent!
    @IBOutlet weak var skipButton: UIButtonComponent!
    
    private let urlOpener: URLOpener
    private let notification: UpgradeNotification
    
    weak var delegate: UpgradeViewControllerDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         urlOpener: URLOpener,
         notification: UpgradeNotification) {
        self.urlOpener = urlOpener
        self.notification = notification
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: AppInitializationBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = notification.titleText
        messageLabel.text = notification.upgradeText

        updateButton.setTitle(notification.upgradeActionText, for: .normal)
        skipButton.setTitle(notification.cancelActionText, for: .normal)

        if notification.notificationType == .mandatory {
            skipButton.isHidden = true
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        urlOpener.open(url: AppConfiguration.appStoreUrl)
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        delegate?.upgradeViewControllerSkipped(self)
    }
}

protocol UpgradeViewControllerDelegate: class {
    func upgradeViewControllerSkipped(_: UpgradeViewController)
}
