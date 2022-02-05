//
//  RDCDepositLandingViewController.swift
//  mRDC
//
//  Created by Chris Carranza on 11/15/18.
//

import UIKit
import ComponentKit
import Localization
import RxSwift
import RxRelay
import InAppRatingApi
import Analytics

protocol RDCDepositFlowDelegate: class {
    func depositFlowDidFinish(success: Bool)
}

final class RDCDepositLandingViewController: UIViewControllerComponent {
    
    private let depositViewControllerFactory: RDCDepositViewControllerFactory
    private let inAppRatingManager: InAppRatingManager
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var depositStackedMenuView: StackedMenuView!
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         depositViewControllerFactory: RDCDepositViewControllerFactory,
         inAppRatingManager: InAppRatingManager) {
        self.depositViewControllerFactory = depositViewControllerFactory
        self.inAppRatingManager = inAppRatingManager
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = UIImage(named: "LandingBG", in: RDCBundle.bundle, compatibleWith: nil)
        
        depositStackedMenuView.titleLabel.text = l10nProvider.localize("dashboard.widget.deposit.btn.launch")
        depositStackedMenuView.imageView.image = UIImage(named: "RdcIcon", in: RDCBundle.bundle, compatibleWith: nil)
        depositStackedMenuView.titleLabel.isAccessibilityElement = false
        depositStackedMenuView.imageView.isAccessibilityElement = false
        depositStackedMenuView.isAccessibilityElement = true
        depositStackedMenuView.accessibilityLabel = l10nProvider.localize("dashboard.widget.deposit.btn.launch.altText")
        depositStackedMenuView.accessibilityTraits = .button
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inAppRatingManager.engage(event: "rdc:viewed", fromViewController: self)
    }
    
    @IBAction func depositStackedMenuViewTapped(_ sender: Any) {
        let depositViewController = depositViewControllerFactory.create()
        depositViewController.delegate = self
        
        let viewController = UINavigationControllerComponent(rootViewController: depositViewController)
        
        present(viewController, animated: true, completion: nil)
    }
}

extension RDCDepositLandingViewController: TrackableScreen {
    var screenName: String {
        return "RDC Landing"
    }
}

extension RDCDepositLandingViewController: RDCDepositFlowDelegate {
    func depositFlowDidFinish(success: Bool) {
        dismiss(animated: true) {
            (self.navigationController as? UINavigationControllerComponent)?.setNeedsNavigationStyleAppearanceUpdate()
            if success {
                self.inAppRatingManager.engage(event: "RDC", fromViewController: self)
            }
        }
    }
}
