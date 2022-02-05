//
//  SessionExpirationWarningPresentationController.swift
//  D3 Banking
//
//  Created by Branden Smith on 9/10/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import UIKit

final class SessionExpirationWarningPresentationController: UIPresentationController {

    private var dimmingView: UIView?

    override var frameOfPresentedViewInContainerView: CGRect {
        let necessaryHeight = (presentedViewController as? SessionExpirationWarningViewController)?.view.bounds.height ?? 210

        return CGRect(
            x: 10.0,
            y: (containerView!.bounds.height / 2) - (necessaryHeight / 2),
            width: containerView!.bounds.width - 20.0,
            height: necessaryHeight
        )
    }

    override func presentationTransitionWillBegin() {
        dimmingView = UIView(frame: containerView!.bounds)
        dimmingView?.backgroundColor = .black
        dimmingView?.alpha = 0

        guard let containerView = self.containerView,
            let coordinator = presentingViewController.transitionCoordinator,
            let dimmingView = self.dimmingView else { return }

        containerView.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make
                .edges
                .equalTo(containerView)
        }

        coordinator.animate(alongsideTransition: { (_) in
            dimmingView.alpha = 0.7
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }

        dimmingView?.removeFromSuperview()
    }
}
