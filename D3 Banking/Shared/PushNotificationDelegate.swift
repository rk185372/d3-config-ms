//
//  PushNotificationDelegate.swift
//  D3 Banking
//
//  Created by Branden Smith on 8/16/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import CardControlApi
import Logging
import UIKit
import UserNotifications
import Utilities
import RxCocoa

protocol PushNotificationDelegate: AnyObject {
    func registerForPushNotifications(in application: UIApplication, withNotificationCenter notificationCenter: UNUserNotificationCenter)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

final class AppPushNotificationDelegate: NSObject, PushNotificationDelegate {
    var tokenHandler: PushNotificationTokenHandler
    let cardControlPushHandler: CardControlPushHandler
    let registrationResolved: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    init(tokenHandler: PushNotificationTokenHandler, cardControlPushHandler: CardControlPushHandler) {
        self.tokenHandler = tokenHandler
        self.cardControlPushHandler = cardControlPushHandler
    }

    func registerForPushNotifications(in application: UIApplication, withNotificationCenter notificationCenter: UNUserNotificationCenter) {
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            log.debug("User authorized push notifications: \(authorized)")

            if !authorized {
                self.registrationResolved.accept(true)
            }

            if let authorizationError = error {
                log.error(
                    "Error obtaining push notification permission error: \(authorizationError)",
                    context: authorizationError
                )
            }
        }

        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert the token to a hex string here to be sent to the server. The server should have no
        // problem converting this string.
        let token = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })

        #if DEBUG
        log.debug("Push notification token received, token: \(token)")
        #else
        log.debug("Push notification token received")
        #endif

        tokenHandler.pushId = token
        registrationResolved.accept(true)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error(
            "The app failed to register for remote notifications with error: \(error)",
            context: error
        )
        self.registrationResolved.accept(true)
    }
}

extension AppPushNotificationDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if cardControlPushHandler.shouldHandleNotification(userInfo: notification.request.content.userInfo) {
            cardControlPushHandler.handleNotification(userInfo: notification.request.content.userInfo, completionHandler: { _ in })
        } else {
            completionHandler([.alert, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if cardControlPushHandler.shouldHandleNotification(response: response) {
            cardControlPushHandler.handleNotification(response: response)
        }
        completionHandler()
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if cardControlPushHandler.shouldHandleNotification(userInfo: userInfo) {
            cardControlPushHandler.handleNotification(userInfo: userInfo, completionHandler: completionHandler)
        }
    }
}
