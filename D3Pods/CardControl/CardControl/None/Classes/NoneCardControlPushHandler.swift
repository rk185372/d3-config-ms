//
//  NoneCardControlPushHandler.swift
//  CardControl
//
//  Created by Elvin Bearden on 3/3/21.
//

import Foundation
import CardControlApi

class NoneCardControlPushHandler: CardControlPushHandler {
    var deferredNotification: [AnyHashable: Any]?

    func shouldHandleUrl(url: URL) -> Bool { return false }
    func shouldHandleNotification(response: UNNotificationResponse) -> Bool { return false }
    func shouldHandleNotification(userInfo: [AnyHashable: Any]) -> Bool { return false }

    func handleUrl(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {}
    func handleNotification(response: UNNotificationResponse) {}
    func handleDeferredNotification() {}
    func handleNotification(userInfo: [AnyHashable: Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
}
