//
//  UINavigationControllerComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/31/18.
//

import UIKit
import RxSwift
import RxRelay

open class UINavigationControllerComponent: UINavigationController, UINavigationControllerDelegate {

    private var bag = DisposeBag()
    private var styleItemDisposeBag = DisposeBag()
    private var badgeManager: TabBarBadgeManager?
    private var badgeMoreViewManager: TabBarBadgeMoreViewManager?
    public var badgeOnMoreView: BadgeOnMoreView?

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        setNavigationBarStyle(viewController)
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        let viewController = super.popViewController(animated: animated)
        
        if let topViewController = topViewController {
            setNavigationBarStyle(topViewController)
        }
        
        return viewController
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToViewController(viewController, animated: animated)
        
        if let topViewController = topViewController {
            setNavigationBarStyle(topViewController)
        }
        
        return viewControllers
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToRootViewController(animated: animated)
        
        if let topViewController = topViewController {
            setNavigationBarStyle(topViewController)
        }
        
        return viewControllers
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        if let topViewController = topViewController {
            setNavigationBarStyle(topViewController)
        }
    }
    
    private func setNavigationBarStyle(_ viewController: UIViewController) {
        guard let customVC = viewController as? UIViewControllerComponent else { return }
        let navStyleItem = customVC.navigationStyleItem
        styleItemDisposeBag = DisposeBag()

        navStyleItem
            .tintColorObservable
            .subscribe(onNext: { [unowned self](color) in
                guard let color = color else { return }
                self.navigationBar.tintColor = color
            })
            .disposed(by: styleItemDisposeBag)
        
        navStyleItem
            .barTintColorObservable
            .subscribe(onNext: { [unowned self](color) in
                guard let color = color else { return }
                self.navigationBar.barTintColor = color
            })
            .disposed(by: styleItemDisposeBag)
        
        navStyleItem
            .shadowImageObservable
            .subscribe(onNext: { [unowned self](image) in
                self.navigationBar.shadowImage = image
            })
            .disposed(by: styleItemDisposeBag)
        
        navStyleItem
            .titleAttributesObservable
            .subscribe(onNext: { [unowned self](attributes) in
                var textAttributes: [NSAttributedString.Key: Any] = [:]
                if let color = attributes.0 {
                    textAttributes[.foregroundColor] = color
                }
                if let font = attributes.1 {
                    textAttributes[.font] = font
                }
                self.navigationBar.titleTextAttributes = textAttributes
            })
            .disposed(by: styleItemDisposeBag)
        
        navStyleItem
            .isTranslucentObservable
            .subscribe(onNext: { [unowned self](isTranslucent) in
                self.navigationBar.isTranslucent = isTranslucent
            })
            .disposed(by: styleItemDisposeBag)
    }
    
    open func setNeedsNavigationStyleAppearanceUpdate() {
        if let topViewController = topViewController {
            setNavigationBarStyle(topViewController)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.setNeedsNavigationStyleAppearanceUpdate()
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
        // This is to set the navigation style back to the previous view controller
        // if the interactive transition is cancelled without completion
        transitionCoordinator?.notifyWhenInteractionChanges({ (context) in
            if context.isCancelled {
                if let fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from) {
                    self.setNavigationBarStyle(fromViewController)
                }
            }
        })
    }

    public func shouldShowBadge() -> Bool {
        guard let controllers = self.tabBarController?.viewControllers,
            let numberOfItems = self.tabBarController?.tabBar.items?.count,
             controllers.count > numberOfItems else { return true }
        let moreViewControllers = controllers[(numberOfItems - 1)...(controllers.count - 1)]
        return moreViewControllers.contains(self) == false
    }
}

extension UINavigationControllerComponent: BadgeManager {
    public func set(badgeManager: TabBarBadgeManager) {
        self.badgeManager = badgeManager

        self.badgeManager?
            .badgeCount
            .subscribe(onNext: { [unowned self] badgeCount in
                guard self.shouldShowBadge() else {
                    self.tabBarItem.badgeValue = nil
                    badgeManager.componentStyle.style(component: self.tabBarItem)
                    return
                }

                if badgeCount <= 0 {
                    self.tabBarItem.badgeValue = nil
                } else if badgeCount < 100 {
                    self.tabBarItem.badgeValue = String(describing: badgeCount)
                } else {
                    self.tabBarItem.badgeValue = "99+"
                }
                badgeManager.componentStyle.style(component: self.tabBarItem)
            })
            .disposed(by: bag)
    }
}

extension UINavigationControllerComponent: BadgeMoreViewManager {
    public func set(badgeMoreViewManager: TabBarBadgeMoreViewManager, type: BadgeMoreViewManagerType) {
        self.badgeMoreViewManager = badgeMoreViewManager

        self.badgeMoreViewManager?
            .badgeCount
            .subscribe(onNext: { [unowned self] badgeCount in
                if !self.shouldShowBadge() {
                    self.tabBarItem.badgeValue = nil
                }
                if badgeCount > 0, let rootViewController = self.viewControllers.first as? UIViewControllerComponent {
                    if badgeCount <= 100 {
                        self.badgeOnMoreView = BadgeOnMoreView(
                            l10nProvider: rootViewController.l10nProvider,
                            type: type,
                            count: String(describing: badgeCount)
                        )
                    } else {
                        self.badgeOnMoreView = BadgeOnMoreView(
                            l10nProvider: rootViewController.l10nProvider,
                            type: type,
                            count: "99+"
                        )
                    }
                    badgeMoreViewManager.componentStyle.style(component: self.badgeOnMoreView!)
                }
            })
            .disposed(by: bag)
    }
    
    public func hasTabBarBadgeMoreViewManager() -> Bool {
        return self.badgeMoreViewManager != nil
    }
}
