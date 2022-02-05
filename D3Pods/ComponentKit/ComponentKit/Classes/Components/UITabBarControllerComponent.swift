//
//  UITabBarControllerComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 8/30/18.
//

import UIKit
import Localization
import RxSwift

open class UITabBarControllerComponent: UITabBarController {
    @IBInspectable public var styleKey: String?
    
    public let l10nProvider: L10nProvider
    public let componentStyleProvider: ComponentStyleProvider
    private weak var originalTableDelegate: UITableViewDelegate?
    private weak var originalTableDataSource: UITableViewDataSource?
    
    public static var switchingAllowedDictionary: [String: Any?] = [:]
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                styleKey: TabBarControllerStyleKey? = nil,
                nibName: String? = nil,
                bundle: Bundle? = nil) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.styleKey = styleKey?.rawValue
        super.init(nibName: nibName, bundle: bundle)
        delegate = self
        moreNavigationController.delegate = self
        let navigationBarStyle: ViewControllerNavigationBarStyle = componentStyleProvider["navigationBarOnDefault"]
        navigationBarStyle.style(navigationController: moreNavigationController)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This happens on view will appear in order to properly style the tint of the more
        // view controllers icon tint color.
        if let styleKey = styleKey {
            let componentStyle: AnyComponentStyle = componentStyleProvider[styleKey]
            componentStyle.style(component: self)
        }
    }
}

extension UITabBarControllerComponent: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.moreNavigationController && originalTableDelegate == nil {
            // Intercept internal TableView to capture the delegate
            if let moreTableView = tabBarController.moreNavigationController.topViewController?.view as? UITableView {
                originalTableDelegate = moreTableView.delegate
                originalTableDataSource = moreTableView.dataSource
                moreTableView.delegate = self
                moreTableView.dataSource = self
            }
        }
        
        guard viewController == selectedViewController else {
            if let isPaymentInProgress = UITabBarControllerComponent.switchingAllowedDictionary["isTabSwitchingAllowed"]
                as? Bool, !isPaymentInProgress {
                if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) {
                    UITabBarControllerComponent.switchingAllowedDictionary["selectedIndex"] = selectedIndex
                }
                NotificationCenter.default.post(name: .stopTabSwitchNotification, object: nil)
                return false
            }
            return true
        }
        
        func innermostViewController(in viewController: UIViewController) -> UIViewController {
            if let navController = viewController as? UINavigationController, let rootViewController = navController.viewControllers.first {
                return innermostViewController(in: rootViewController)
            }
            return viewController
        }
        
        if let internalNavigationViewController = innermostViewController(in: viewController) as? InternalNavigationViewController {
            internalNavigationViewController.popToNavigationRoot()
            return false
        }
        
        return true
    }
}

extension UITabBarControllerComponent: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {
        guard let firstViewController = moreNavigationController.viewControllers.first else { return }
        
        // Removes the edit button
        if viewController == firstViewController {
            viewController.navigationItem.rightBarButtonItem = nil
        }
    }
}

extension UITabBarControllerComponent {
    private func controller(for indexPath: IndexPath) -> UIViewController? {
        guard let controllers = self.viewControllers,
            let numberItems = self.tabBar.items?.count,
            controllers.count > (numberItems + indexPath.row - 1) else {
                return nil
        }
        return controllers[numberItems + indexPath.row - 1]
    }
    
    public func hasMoreViewElementsWithBadge() -> Bool {
        guard let controllers = self.viewControllers,
            let numberItems = self.tabBar.items?.count,
            controllers.count > numberItems else {
                return false
        }
        let moreViewControllers = controllers[(numberItems - 1)...(controllers.count - 1)]
        let controllersWithBadgeMoreViewManager = moreViewControllers.filter {
            ($0 as? UINavigationControllerComponent)?.hasTabBarBadgeMoreViewManager() == true
        }
        return !controllersWithBadgeMoreViewManager.isEmpty
    }
}

extension UITabBarControllerComponent: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        originalTableDelegate!.tableView!(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Prevent any NotPresentViewController in case it is trying to be displayed.
        // NotPresentViewController helps execute actions when an options is selected in moreNavigationController.
        if let controller = controller(for: indexPath) as? NotPresentViewController {
            tableView.deselectRow(at: indexPath, animated: true)
            NotificationCenter.default.post(name: .notPresentViewControllerSelected, object: controller.actionKey)
            return
        }
        
        originalTableDelegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }
}

extension UITabBarControllerComponent: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return originalTableDataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = originalTableDataSource!.tableView(tableView, cellForRowAt: indexPath)
        if let controller = controller(for: indexPath) as? UINavigationControllerComponent,
            let view = controller.badgeOnMoreView {
            cell.addBadgeView(badgeView: view)
        }
        cell.imageView?.tintColor = cell.textLabel?.textColor
        return cell
    }
}

extension UITableViewCell {
    public func addBadgeView(badgeView: BadgeOnMoreView) {
        layoutIfNeeded()
        if let labelView = contentView.subviews.compactMap({ $0 as? UILabel }).first {
            if let font = labelView.font, let size = labelView.text?.size(withAttributes: [.font: font]) {
                let spanLeft: CGFloat = 15
                badgeView.frame = CGRect(
                    origin: CGPoint(x: labelView.frame.origin.x + size.width + spanLeft, y: badgeView.frame.origin.y),
                    size: CGSize(width: badgeView.frame.size.width, height: frame.height)
                )
            } else {
                // In iOS 12.4 the labelView.text is nil during the first load. In that case the logic
                // uses the labelView element frame, which is bigger than the space required to display the text.
                badgeView.frame = CGRect(
                    origin: CGPoint(x: labelView.frame.maxX, y: badgeView.frame.origin.y),
                    size: CGSize(width: badgeView.frame.size.width, height: frame.height)
                )
            }
        }
        addSubview(badgeView)
    }
}
