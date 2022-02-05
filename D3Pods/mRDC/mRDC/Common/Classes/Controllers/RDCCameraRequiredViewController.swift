//
//  RDCCameraRequiredViewController.swift
//  mRDC
//
//  Created by Chris Carranza on 10/12/18.
//

import UIKit
import ComponentKit
import Localization
import Analytics

final class RDCCameraRequiredViewController: UIViewControllerComponent {
    
    @IBOutlet weak var centerIconView: CenterIconView!
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerIconView.imageView.image = UIImage(named: "CameraRequired", in: RDCBundle.bundle, compatibleWith: nil)!
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension RDCCameraRequiredViewController: TrackableScreen {
    var screenName: String {
        return "RDC Camera Error Screen"
    }
}
