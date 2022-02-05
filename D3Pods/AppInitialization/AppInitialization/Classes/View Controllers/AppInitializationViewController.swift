//
//  AppInitializationViewController.swift
//  Accounts
//
//  Created by Branden Smith on 6/18/18.
//

import UIKit
import RxSwift
import RxCocoa
import Utilities
import ComponentKit
import Localization
import Offline
import Analytics

public final class AppInitializationViewController: UIViewControllerComponent {
    public enum State {
        case initializing
        case error
        case completed
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loadingIndicatorStackView: UIStackView!
    @IBOutlet weak var failureView: UIView!
    
    private let upgradeViewControllerFactory: UpgradeViewControllerFactory
    private let offlineViewControllerFactory: OfflineViewControllerFactory
    private let initializer: AppInitializer
    fileprivate let state = BehaviorRelay(value: State.initializing)

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         upgradeViewControllerFactory: UpgradeViewControllerFactory,
         offlineViewControllerFactory: OfflineViewControllerFactory,
         initializer: AppInitializer) {
        self.upgradeViewControllerFactory = upgradeViewControllerFactory
        self.offlineViewControllerFactory = offlineViewControllerFactory
        self.initializer = initializer
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: AppInitializationBundle.bundle
        )
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = UIImage(named: "Background")

        state.distinctUntilChanged().subscribe(onNext: { [unowned self] (state) in
            switch state {
            case .initializing, .completed:
                self.logoImageView.isHidden = false
                self.loadingIndicatorStackView.isHidden = false
                self.failureView.isHidden = true
                
            case .error:
                self.logoImageView.isHidden = true
                self.loadingIndicatorStackView.isHidden = true
                self.failureView.isHidden = false
            }
        }).disposed(by: bag)

        attemptInitialization()
    }
    
    private func attemptInitialization() {
        state.accept(.initializing)
        initializer.initialize().subscribe(onSuccess: { [unowned self] (result) in
            switch result {
            case .success:
                self.state.accept(.completed)
                
            case .failure:
                self.state.accept(.error)
                
            case .offline:
                self.handleOffline()
                
            case .userInteractionRequired(let interaction):
                self.handle(userInteraction: interaction)
            }
        }).disposed(by: bag)
    }
    
    private func handle(userInteraction: InitializationUserInteraction) {
        switch userInteraction {
        case .upgrade(let notification):
            let viewController = upgradeViewControllerFactory.create(notification: notification)
            viewController.delegate = self
            viewController.isModalInPresentation = true
            present(viewController, animated: true)
        }
    }
    
    private func handleOffline() {
        let viewController = offlineViewControllerFactory.create()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    @IBAction func tryAgainTapped(_ sender: Any) {
        attemptInitialization()
    }
}

extension AppInitializationViewController: TrackableScreen {
    public var screenName: String {
        return "Initialization"
    }
}

extension Reactive where Base == AppInitializationViewController {
    public var state: Driver<AppInitializationViewController.State> {
        return base.state.asDriver()
    }
}

extension AppInitializationViewController: UpgradeViewControllerDelegate {
    func upgradeViewControllerSkipped(_ upgradeViewController: UpgradeViewController) {
        dismiss(animated: true)
        attemptInitialization()
    }
}

extension AppInitializationViewController: OfflineViewControllerDelegate {
    public func offlineViewControllerReachabilityRestored(_ viewController: OfflineViewController) {
        dismiss(animated: true)
        attemptInitialization()
    }
}
