//
//  RootViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/28/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Utilities

public final class RootViewController: UIViewController {
    
    private(set) var viewController: UIViewController?
    
    private static let standardDuration: TimeInterval = 0.3

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        setViewController(viewController, animated: false)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var childForStatusBarStyle: UIViewController? {
        return viewController?.childForStatusBarStyle
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewController?.supportedInterfaceOrientations ?? [.all]
    }

    public func setViewController(_ newViewController: UIViewController,
                                  animated: Bool,
                                  completion: (() -> Void)? = nil) {
        guard self.viewController != newViewController else {
            completion?()
            
            return
        }
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // If we have no initial view controller, then just add the new one [CC] 1/20/17
        guard let oldViewController = viewController else {
            addChild(newViewController)
            view.addSubview(newViewController.view)
            newViewController.view.makeMatch(view: view)
            newViewController.didMove(toParent: self)
            
            view.setNeedsUpdateConstraints()
            
            viewController = newViewController
            
            completion?()
            
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
                duration: RootViewController.standardDuration,
                options: .transitionCrossDissolve,
                animations: { newViewController.view.makeMatch(view: self.view) },
                completion: { _ in
                    newViewController.didMove(toParent: self)
                    oldViewController.view.removeFromSuperview()
                    oldViewController.removeFromParent()
                    completion?()
            })
            
        } else {
            oldViewController.willMove(toParent: nil)
            addChild(newViewController)
            view.addSubview(newViewController.view)
            newViewController.view.makeMatch(view: view)
            newViewController.didMove(toParent: self)
            
            viewController = newViewController
            
            setNeedsStatusBarAppearanceUpdate()
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParent()
            
            completion?()
        }
    }
}
