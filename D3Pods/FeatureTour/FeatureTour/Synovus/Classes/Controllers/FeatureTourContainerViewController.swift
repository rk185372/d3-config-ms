//
//  FeatureTourContainerViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/9/19.
//

import UIKit
import SnapKit
import ComponentKit
import Localization
import RxSwift
import RxCocoa
import Analytics

final class FeatureTourContainerViewController: UIViewControllerComponent {
    
    private let featureTourContent: FeatureTourContent
    
    private var controllerQueue: [FeatureTourContentViewController] = []
    
    private var viewController: UIViewController?
    
    fileprivate let _featureTourCompleted: PublishRelay<Void> = PublishRelay()
    
    override var childForStatusBarStyle: UIViewController? {
        return viewController
    }
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                featureTourContent: FeatureTourContent) {
        self.featureTourContent = featureTourContent
        controllerQueue = featureTourContent.contentViewControllers
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "FeatureTourContainerViewController",
            bundle: FeatureTourBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextScreen(animated: false)
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular) ? .all : .portrait
    }
    
    fileprivate func nextScreen(animated: Bool) {
        if controllerQueue.isEmpty {
            _featureTourCompleted.accept(())
        } else {
            let vc = controllerQueue.removeFirst()
            vc.delegate = self
            setViewController(vc, animated: animated)
        }
    }
    
    private func setViewController(_ newViewController: UIViewController,
                                   animated: Bool) {
        guard self.viewController != newViewController else {
            return
        }
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let oldViewController = viewController else {
            addChild(newViewController)
            view.addSubview(newViewController.view)
            newViewController.view.snp.makeConstraints { make in
                make
                    .edges
                    .equalTo(self.view)
            }
            newViewController.didMove(toParent: self)
            
            view.setNeedsUpdateConstraints()
            
            viewController = newViewController
            
            return
        }
        
        if animated {
            oldViewController.willMove(toParent: nil)
            addChild(newViewController)
            
            viewController = newViewController
            
            setNeedsStatusBarAppearanceUpdate()
            transition(
                from: oldViewController,
                to: newViewController,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    newViewController.view.snp.makeConstraints { make in
                        make
                            .edges
                            .equalTo(self.view)
                    }
                },
                completion: { _ in
                    newViewController.didMove(toParent: self)
                    oldViewController.view.removeFromSuperview()
                    oldViewController.removeFromParent()
            })
            
        } else {
            oldViewController.willMove(toParent: nil)
            addChild(newViewController)
            view.addSubview(newViewController.view)
            newViewController.view.snp.makeConstraints { make in
                make
                    .edges
                    .equalTo(self.view)
            }
            newViewController.didMove(toParent: self)
            
            viewController = newViewController
            
            setNeedsStatusBarAppearanceUpdate()
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParent()
        }
    }
}

extension FeatureTourContainerViewController: TrackableScreen {
    var screenName: String {
        return "FeatureTour"
    }
}

extension FeatureTourContainerViewController: ContentViewDelegate {
    func proceedToNextScreen() {
        nextScreen(animated: true)
    }
    
    func proceedToLogin() {
        featureTourContent.hasSeenFeatureTour = true
        _featureTourCompleted.accept(())
    }
}

extension Reactive where Base == FeatureTourContainerViewController {
    var featureTourCompleted: Observable<Void> {
        return base._featureTourCompleted.asObservable()
    }
}
