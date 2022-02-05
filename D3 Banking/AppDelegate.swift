//
//  AppDelegate.swift
//  D3 Banking
//
//  Created by Chris Carranza on 3/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Analytics
import AppInitialization
import Authentication
import AuthFlow
import UIKit
import GBVersionTracking
import AlamofireNetworkActivityIndicator
import Dip
import Localization
import LocalizationData
import ComponentKit
import Branding
import Utilities
import AppConfiguration
import RootViewController
import Web
import Navigation
import Enablement
import UserNotifications
import Messages
import RxSwift
import RxRelay
import SwiftyBeaver
import Logging
import os
import Firebase
import D3FlipperThemeLoader
import Session
import WebKit
import CardControlApi

// Important! The @UIApplicationMain attribute is commented out, but I have deliberately left it in the file as
// a reminder that we have implemented our own main.swift file for the application startup. We have done this
// so that we can subclass UIApplication to intercept all touch events and update the SessionTimeoutManager singleton's last
// activity stamp
//@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()
    
    var dependencyContainer: DependencyContainer!
    var root: ApplicationRoot?

    let bag = DisposeBag()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Disable animations in UITests. The #if DEBUG is here for redundancy as an extra
        // check to make sure that this never gets to production.
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UITests") {
            UIApplication.shared.keyWindow?.layer.speed = 0
            UIView.setAnimationsEnabled(false)
            let userDefaults = UserDefaults(suiteName: AppConfiguration.applicationGroup)!
            userDefaults.removeObject(forKey: "AuthUserStore")
            userDefaults.removeObject(forKey: "LastlogSignedAccount")
        }
        #endif
                        
        FirebaseApp.configure()
        setupLog()
        GBVersionTracking.track()

        //Start the shared network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true

        setupDependencyContainer()
        
        let themeParser: ThemeParser = try! dependencyContainer.resolve()

        _ = FlipperInitalizer(theme: themeParser.theme!)
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always

        loadRootViewController()

        // Registering for push notifications must happen after the root is created in the
        // loadRootViewController call. This call must follow the call to
        // loadRootViewController
        registerForPushNotifications(in: application)

        let tracker: ScreenAnalyticsTracker = try! dependencyContainer.resolve()
        
        do {
            try tracker.trackViewControllers()
        } catch {
            print(error)
        }

        // Bootstrapping the dc resolves all EagerSingleton instances and
        // prevents anything from being inserted into the graph.
        try! dependencyContainer.bootstrap()

        // After the container is bootstrapped, we we need to setup some basic
        // info on the crashlytics instance.
        addCustomKeysToCrashlytics()

        setupCardControl(with: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary
        // interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the
        // transition to the background state. Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering
        // callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information
        // to restore your application to its current state in case it is terminated later. If your application supports background
        // execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously
        // in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func loadRootViewController() {
        do {
            root = try dependencyContainer.resolve() as ApplicationRoot
        } catch {
            fatalError("Could not resolve application root: \(error)")
        }
        
        window?.rootViewController = try! dependencyContainer.resolve() as RootViewController
        window?.makeKeyAndVisible()
    }

    private func registerForPushNotifications(in application: UIApplication) {
        // We want to check the command line arguments and skip push notification registration
        // in test targets.
        guard !ProcessInfo.processInfo.arguments.contains("-disableNotificationRegistration") else { return }

        root?.pushNotificationDelegate.registerForPushNotifications(
            in: application,
            withNotificationCenter: UNUserNotificationCenter.current()
        )
    }

    private func setupLog() {
        log.addDestination(getOSLogDestination())
        log.addDestination(getConsoleDestination())

        #if !DEBUG
        log.addDestination(getCrashlyticsDestination(crashlytics: Crashlytics.crashlytics()))
        #endif
    }

    private func addCustomKeysToCrashlytics() {
        let uuid: D3UUID = try! dependencyContainer.resolve()
        Crashlytics.crashlytics().setCustomValue(uuid.uuidString, forKey: "uuid")
    }

    private func setupCardControl(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let cardControl: CardControlManager = try! dependencyContainer.resolve()
        root?.pushNotificationDelegate
            .registrationResolved
            .skipWhile { !$0 }
            .flatMap { _ in
                cardControl.setup()  
            }
            .subscribe(onNext: { _ in
                cardControl.applicationLaunched(with: launchOptions)
            }, onError: { error in
                log.error(error)
            }).disposed(by: bag)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        root?.pushNotificationDelegate.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        root?.pushNotificationDelegate.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        root?.pushNotificationDelegate.application(
            application,
            didReceiveRemoteNotification: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }
}
