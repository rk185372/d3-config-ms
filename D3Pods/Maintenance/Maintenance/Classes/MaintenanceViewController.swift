//
//  MaintenanceViewController.swift
//  Maintenance
//
//  Created by Andrew Watt on 8/3/18.
//

import UIKit
import ComponentKit
import Localization
import Analytics

public final class MaintenanceViewController: UIViewControllerComponent {
    @IBOutlet weak var messageLabel: UILabelComponent!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var centerIconView: CenterIconView!
    
    var message: String? {
        get {
            return messageLabel.text
        }
        set {
            messageLabel.text = newValue
        }
    }

    public init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: MaintenanceBundle.bundle
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = UIImage(named: "FullLogo")
        centerIconView.imageView.image = UIImage(named: "Maintenance")
    }
}

extension MaintenanceViewController: TrackableScreen {
    public var screenName: String {
        return "Maintenance"
    }
}
