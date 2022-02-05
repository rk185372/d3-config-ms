//
//  CardControlManager.swift
//  CardControlApi
//
//  Created by Elvin Bearden on 2/1/21.
//

import Foundation
import RxSwift
import RxCocoa

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

/// `CardControlManager`
public protocol CardControlManager {
    /// Relay to report errors from the CardControl SDK
    var errorRelay: BehaviorRelay<CardControlError?> { get }
    
    /// Perform any required setup for the CardControl functionality
    func setup() -> Observable<Void>

    /// Perform any deep linking or data passing to the CardControl functionality on launch
    func applicationLaunched(with options: LaunchOptions?)
    
    /// Launch the CardControl flow and show a loading spinner if
    /// loading presenter is not nil
    func launchCardControls(loadingPresenter: UIViewController?)
}

public protocol CardControlPushHandler {
    /// Store a notification to present later, such as after login
    var deferredNotification: [AnyHashable: Any]? { get }

    /// Should the CardControl handle the url
    func shouldHandleUrl(url: URL) -> Bool

    /// Should CardControl handle the notification
    func shouldHandleNotification(response: UNNotificationResponse) -> Bool

    /// Should CardControl handle the notification
    func shouldHandleNotification(userInfo: [AnyHashable: Any]) -> Bool

    /// Handle the url
    func handleUrl(url: URL, options: [UIApplication.OpenURLOptionsKey: Any])

    /// Handle the notification
    func handleNotification(response: UNNotificationResponse)

    /// Handle a deferred notification if one exists
    func handleDeferredNotification()

    /// Handle the notification
    func handleNotification(userInfo: [AnyHashable: Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

public struct CardControlBranding {
    public let primaryColor: UIColor
    public let secondaryColor: UIColor

    public init(primaryColor: UIColor, secondaryColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
}

public enum CardControlError: Error {
    case initialize(String)
    case launch(String)
}
