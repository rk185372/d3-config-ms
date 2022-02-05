//
//  AuthGenericViewController.swift
//  AuthFlow
//
//  Created by Chris Carranza on 6/8/18.
//

import UIKit
import ComponentKit
import Localization

open class AuthGenericViewController: UIViewControllerComponent {
    
    @IBOutlet public weak var headerView: UIView!
    @IBOutlet weak var logoImageView: UIImageViewComponent!
    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var buttonsStackView: UIStackView!
    @IBOutlet private var contentCenterY: NSLayoutConstraint!
    
    public init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "AuthGenericViewController",
            bundle: AuthGenericViewControllerBundle.bundle
        )
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = UIImage(named: "FullLogo")
    }
    
    // TODO: Pending some decisions from the design team, we will probably want to remove this
    // alert and modify those areas calling this method to show errors in a more user friendly
    // way.
    public func showErrorAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(
            title: title ?? l10nProvider.localize("app.error.generic.title"),
            message: message ?? l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default))
        self.present(alert, animated: true)
    }
    
    public var allowContentScrolling: Bool = false {
        didSet {
            contentCenterY.isActive = !allowContentScrolling
        }
    }
}
