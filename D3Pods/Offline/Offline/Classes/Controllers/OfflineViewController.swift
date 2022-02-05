//
//  OfflineViewController.swift
//  Offline
//
//  Created by Andrew Watt on 9/21/18.
//

import UIKit
import ComponentKit
import Localization
import Alamofire
import RxSwift

public final class OfflineViewController: UIViewControllerComponent {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var centerIconView: CenterIconView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private let monitor: ReachabilityMonitor?
    
    public weak var delegate: OfflineViewControllerDelegate?
    
    public init(config: ComponentConfig, monitor: ReachabilityMonitor?) {
        self.monitor = monitor
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: OfflineBundle.bundle
        )
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = UIImage(named: "FullLogo")
        centerIconView.imageView.image = UIImage(named: "Offline")
        
        monitor?.status
            .debounce(ReachabilityMonitor.debounceInterval)
            .asObservable()
            .filter { $0.isReachable }
            .take(1)
            .subscribe(onNext: { [unowned self] _ in
                self.delegate?.offlineViewControllerReachabilityRestored(self)
            })
            .disposed(by: bag)
    }
}

public protocol OfflineViewControllerDelegate: class {
    func offlineViewControllerReachabilityRestored(_ viewController: OfflineViewController)
}
