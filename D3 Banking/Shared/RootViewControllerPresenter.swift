//
//  RootViewControllerPresenter.swift
//  D3 Banking
//
//  Created by Andrew Watt on 7/9/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Dip
import UIKit
import RootViewController
import Utilities
import RxSwift
import RxRelay
import AuthFlow
import Navigation
import AppInitialization
import Maintenance
import Dashboard
import Logout
import Logging
import FeatureTour
import CardControlApi

final class RootViewControllerPresenter: RootPresenter {
    struct Presentables {
        var initialization: AppInitializationPresentable
        var featureTour: FeatureTourPresentable
        var authentication: AuthPresentable
        var dashboard: DashboardPresentable
        var maintenance: MaintenancePresentable
        var logout: LogoutPresentable
    }

    var view = RootView.initializing(suppressAutoPrompt: false) {
        didSet {
            if oldValue != view {
                transition(to: view)
            }
        }
    }

    private let rootViewController: RootViewController
    private let presentables: Presentables
    private let bag = DisposeBag()
    private let navigationProvider: NavigationProvider
    private let buildInfoViewControllerFactory: ViewControllerFactory?

    private weak var dependencyContainer: DependencyContainer?
    private var hasDeferredNotification = false

    init(rootViewController: RootViewController,
         presentables: Presentables,
         application: D3UIApplication,
         navigationProvider: NavigationProvider,
         dependencyContainer: DependencyContainer,
         buildInfoViewControllerFactory: ViewControllerFactory? = nil) {
        self.rootViewController = rootViewController
        self.presentables = presentables
        self.navigationProvider = navigationProvider
        self.dependencyContainer = dependencyContainer
        self.buildInfoViewControllerFactory = buildInfoViewControllerFactory

        application
            .rx
            .shakeEvents
            .subscribe({ [unowned self] _ in
                self.handleShakeEvent()
            })
            .disposed(by: bag)
        
        transition(to: view)
    }

    public func advance(from previousView: RootView) {
        if let newView = view(following: previousView) {
            view = newView
        }
    }
    
    public func present(view: RootView) {
        self.view = view
    }

    private func transition(to newView: RootView) {
        log.debug("RootPresenter transitioning to \(newView)")
        
        let viewController = self.viewController(forView: newView)

        defer {
            if hasDeferredNotification {
                hasDeferredNotification = false

                let notificationHandler: CardControlPushHandler = try! dependencyContainer!.resolve()
                notificationHandler.handleDeferredNotification()
            }
        }
        // Any presented view controllers need to be dismissed when transitioning
        // or else they will remain in front of the user.
        self.rootViewController.dismiss(animated: true, completion: nil)
        self.rootViewController.setViewController(viewController, animated: true)
    }
    
    private func viewController(forView view: RootView) -> UIViewController {
        switch view {
        case .initializing(let suppressAutoPrompt):
            return presentables.initialization.createViewController(presentingFrom: self, suppressAutoPrompt: suppressAutoPrompt)
        case .featureTour(let suppressAutoPrompt):
            if let featureTour =
                presentables.featureTour.createViewController(presentingFrom: self, suppressAutoPrompt: suppressAutoPrompt) {
                return featureTour
            } else {
                return presentables.authentication.createViewController(presentingFrom: self, suppressAutoPrompt: suppressAutoPrompt)
            }
        case .authenticating(let suppressAutoPrompt):
            return presentables.authentication.createViewController(presentingFrom: self, suppressAutoPrompt: suppressAutoPrompt)
        case .dashboard:
            guard let container = dependencyContainer else { return UIViewController() }

            let notificationHandler: CardControlPushHandler = try! container.resolve()
            hasDeferredNotification = notificationHandler.deferredNotification != nil
            return presentables.dashboard.createViewController(
                presentingFrom: self,
                withTabBarViewControllers: navigationProvider.provideNavigationViewControllers(
                    givenDependencyContainer: container
                )
            )
        case .maintenance(let message):
            return presentables.maintenance.createViewController(presentingFrom: self, withMessage: message)
        case .loggingOut:
            return presentables.logout.createViewController(presentingFrom: self)
        }
    }
    
    private func view(following view: RootView) -> RootView? {
        switch view {
        case .initializing(let suppressAutoPrompt):
            return .featureTour(suppressAutoPrompt: suppressAutoPrompt)
        case .featureTour(let suppressAutoPrompt):
            return .authenticating(suppressAutoPrompt: suppressAutoPrompt)
        case .authenticating:
            return .dashboard
        default:
            return nil
        }
    }

    private func handleShakeEvent() {
        if let vc = buildInfoViewControllerFactory?.create() {
            rootViewController.present(
                UINavigationController(rootViewController: vc),
                animated: true,
                completion: nil
            )
        }
    }
}
