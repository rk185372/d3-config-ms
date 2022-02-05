//
//  DisclosurePresentationController.swift
//  Enablement
//
//  Created by Chris Carranza on 8/10/18.
//

import UIKit
import SnapKit

public final class DisclosurePresentationController: UIPresentationController {
    
    private var dimmingView: UIView?
    private var topInset: CGFloat
    
    public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, topInset: CGFloat) {
        self.topInset = topInset
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.bounds.inset(by: UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0))
    }
    
    public override func presentationTransitionWillBegin() {
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
    
    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        
        dimmingView?.removeFromSuperview()
    }
}
