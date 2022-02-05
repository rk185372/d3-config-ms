//
//  OnDotCardControlPushHandler.swift
//  CardControl
//
//  Created by Elvin Bearden on 3/2/21.
//

import Foundation
import CardControlApi
import CardAppMobile
import RxSwift
import Session

class OnDotCardControlPushHandler: CardControlPushHandler {
    var deferredNotification: [AnyHashable: Any]?

    private let senderKey = "sender"
    private let senderValue = "ondot"
    private let userSession: UserSession

    init(userSession: UserSession) {
        self.userSession = userSession
    }

    func shouldHandleUrl(url: URL) -> Bool {
        guard let sender = getQueryItems(url: url).first(where: { $0.name == senderKey }) else {
            return false
        }
        
        return sender.value?.lowercased() == senderValue
    }

    func shouldHandleNotification(response: UNNotificationResponse) -> Bool {
        guard let sender = response.notification.request.content.userInfo[senderKey] as? String else {
            return false
        }

        return sender.lowercased() == senderValue
    }

    func shouldHandleNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard let sender = userInfo[senderKey] as? String else { return false }
        return sender.lowercased() == senderValue
    }

    func handleUrl(url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
        guard let sdk = CardAppSDK.shared else { return }
        _ = sdk.open(url: url, options: options)
    }

    func handleNotification(response: UNNotificationResponse) {
        guard let sdk = CardAppSDK.shared, userSession.rawSession != nil else {
            deferredNotification = response.notification.request.content.userInfo
            return
        }

        deferredNotification = nil
        _ = sdk.receivedNotificationResponse(response)
    }

    func handleDeferredNotification() {
        guard let deferred = deferredNotification else { return }
        handleNotification(userInfo: deferred) { _ in }
    }

    func handleNotification(userInfo: [AnyHashable: Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let sdk = CardAppSDK.shared else { return }
        guard userSession.rawSession != nil else {
            deferredNotification = userInfo
            completionHandler(.noData)
            return
        }

        deferredNotification = nil

        let sdkWillHandle = sdk.receivedPushNotification(
            withUserInfo: userInfo,
            fetchCompletionHandler: completionHandler
        )

        if !sdkWillHandle {
            completionHandler(.noData)
        }
    }

    private func getQueryItems(url: URL) -> [URLQueryItem] {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }
}
