//
//  DashboardViewController.swift
//  Dashboard
//
//  Created by Andrew Watt on 9/25/18.
//

import UIKit
import ComponentKit
import RxSwift
import UserNotifications
import Localization
import Offline
import SessionExpiration
import InAppRatingApi
import Messages
import Views

public final class DashboardViewController: UITabBarControllerComponent {
    private let minimumOfflineNotificationInterval: DispatchTimeInterval = .seconds(2)
    
    private var visible = false
    private let bag = DisposeBag()
    private let sessionExpirationWarningManager: SessionExpirationWarningManager
    private let monitor: ReachabilityMonitor?
    private let inAppRatingManager: InAppRatingManager
    private let messageStatsManager: MessageStatsManager
    private let landingFlow: DashboardLandingFlow
    private var badgeManager: TabBarBadgeManager?
    private lazy var loadingView = {
        return LoadingView(
            activityIndicatorColor: .white,
            backgroundColor: UIColor.black.withAlphaComponent(0.4)
        )
    }()
    
    init(config: ComponentConfig,
         sessionExpirationWarningManager: SessionExpirationWarningManager,
         monitor: ReachabilityMonitor?,
         inAppRatingManager: InAppRatingManager,
         messageStatsManager: MessageStatsManager,
         landingFlow: DashboardLandingFlow) {
        self.sessionExpirationWarningManager = sessionExpirationWarningManager
        self.monitor = monitor
        self.inAppRatingManager = inAppRatingManager
        self.messageStatsManager = messageStatsManager
        self.landingFlow = landingFlow
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            styleKey: .tabBarPrimary,
            nibName: nil,
            bundle: nil
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        inAppRatingManager
            .obtainPromptStatus()
            .subscribe()
            .disposed(by: bag)
        
        monitor?.status
            .filter { $0.isNotReachable }
            .throttle(minimumOfflineNotificationInterval, latest: false)
            .drive(onNext: { [unowned self] _ in
                if self.visible {
                    self.showOfflineNotification()
                }
            })
            .disposed(by: bag)
        
        sessionExpirationWarningManager
            .presentWarningViewController
            .subscribe(onNext: { [unowned self] warningViewController in
                guard let warningViewController = warningViewController,
                    let selectedViewController = self.selectedViewController else { return }
                let topViewController = self.topViewController(fromRoot: selectedViewController)
                topViewController.present(warningViewController, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.visible = true

        if hasMoreViewElementsWithBadge() {
            set(
                badgeManager: TabBarBadgeManager(
                    badgeCount: messageStatsManager.alertsCount,
                    styleProvider: componentStyleProvider
                )
            )
        }
        
        landingFlow.start(on: self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.visible = false
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }
    
    private func showOfflineNotification() {
        let content = UNMutableNotificationContent()
        content.body = l10nProvider.localize("app.offline.connect-message")
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .leastNonzeroMagnitude, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func topViewController(fromRoot root: UIViewController) -> UIViewController {
        if root.presentedViewController == nil {
            return root
        }
        
        if let vc = root.presentedViewController as? UINavigationController {
            return topViewController(fromRoot: vc.topViewController!)
        }
        
        return root.presentedViewController!
    }

    public func showLoadingView() {
        let topController = topViewController(fromRoot: self)
        topController.view.addSubview(loadingView)
        topController.view.bringSubviewToFront(loadingView)
        loadingView.spinner.isHidden = false
        loadingView.spinner.startAnimating()
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    public func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
}

extension DashboardViewController: BadgeManager {
    public func set(badgeManager: TabBarBadgeManager) {
        self.badgeManager = badgeManager

        self.badgeManager?
            .badgeCount
            .subscribe(onNext: { [unowned self] badgeCount in
                if let moreBarItem = self.tabBar.items?.last {
                    moreBarItem.badgeValue = (badgeCount > 0) ? "" : nil
                    badgeManager.componentStyle.style(component: moreBarItem)
                }
            })
            .disposed(by: bag)
    }
}
