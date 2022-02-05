//
//  SessionExpirationWarningManager.swift
//  D3 Banking
//
//  Created by Branden Smith on 9/10/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Logging 
import Navigation
import RxSwift
import RxRelay
import Utilities
import UserInteraction

public final class SessionExpirationWarningManager: NSObject {

    private let sessionExpirationManager: SessionExpirationManager
    private let warningVCFactory: SessionExpirationWarningVCFactory
    private let userInteraction: UserInteraction
    private let bag = DisposeBag()

    private var presentedWarningController: SessionExpirationWarningViewController?
    
    private let _presentWarningViewController: BehaviorRelay<UIViewController?> = BehaviorRelay(value: nil)
    public var presentWarningViewController: Observable<UIViewController?> {
        return _presentWarningViewController.asObservable()
    }

    init(sessionExpirationManager: SessionExpirationManager,
         warningVCFactory: SessionExpirationWarningVCFactory,
         userInteraction: UserInteraction) {
        self.sessionExpirationManager = sessionExpirationManager
        self.warningVCFactory = warningVCFactory
        self.userInteraction = userInteraction
        super.init()

        sessionExpirationManager
            .timeoutState
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .timeout:
                    NotificationCenter.default.post(Notification(name: .sessionExpired))
                    self.presentedWarningController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    self.presentedWarningController = nil
                    sessionExpirationManager.touchInterceptionEnabled = true

                case .warning(let secondsRemaining):
                    sessionExpirationManager.touchInterceptionEnabled = false

                    if self.presentedWarningController == nil {
                        let vc = warningVCFactory.create(remainingTime: secondsRemaining, delegate: self)
                        vc.modalPresentationStyle = .custom
                        vc.transitioningDelegate = self
                        
                        self.presentedWarningController = vc
                        self._presentWarningViewController.accept(vc)
                    } else {
                        self.presentedWarningController?.updateRemainingTime(withTime: secondsRemaining)
                    }

                case .clear:
                    self.presentedWarningController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    self.presentedWarningController = nil
                    sessionExpirationManager.touchInterceptionEnabled = true
                }
            })
            .disposed(by: bag)
    }
}

extension SessionExpirationWarningManager: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return SessionExpirationWarningPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}

extension SessionExpirationWarningManager: SessionExpirationWarningViewControllerDelegate {
    func logoutSelected(for viewController: SessionExpirationWarningViewController) {
        log.debug("Logout selected for session timout warning")
        sessionExpirationManager.touchInterceptionEnabled = true
        userInteraction.triggerUserInteraction()
        NotificationCenter.default.post(Notification(name: .sessionExpired))
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func stillHereSelected(for viewController: SessionExpirationWarningViewController) {
        sessionExpirationManager.touchInterceptionEnabled = true
        userInteraction.triggerUserInteraction()
        log.debug("Still here selected for session timeout warning")
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
