//
//  Notifications.swift
//  Utilities
//
//  Created by Andrew Watt on 7/23/18.
//

import Foundation

public extension Notification.Name {
    static let loggedOut = Notification.Name("loggedOut")
    
    /// Posted when the server is down for maintenance.
    ///
    /// **Parameters:**
    /// - `message`: A `String` containing the server maintenance message.
    static let maintenance = Notification.Name("maintenance")
    
    static let userInteractionOccurred = Notification.Name("userInteractionOccurred")
    static let sessionExpired = Notification.Name("sessionExpired")
    static let unauthenticated = Notification.Name("unauthenticated")
    
    static let updatedThemeNotification = Notification.Name("updatedThemeNotification")
    static let updatedL10nNotification = Notification.Name("updatedL10nNotification")
    static let reloadComponentsNotification = Notification.Name("reloadComponentsNotification")
    static let sectionRequiresUpdateNotification = Notification.Name("sectionRequiresUpdateNotification")
    static let snapshotTokenUpdatedNotification = Notification.Name("snapshotTokenUpdatedNotification")
    static let watchAppDidBecomeActive = Notification.Name("watchAppDidBecomeActive")
    static let stopTabSwitchNotification = Notification.Name("stopTabSwitchNotification")
    static let userAccountTypeUpdated = Notification.Name("userAccountTypeUpdated")
    static let reloadWatchComponentsNotification = Notification.Name("reloadWatchComponentsNotification")
    static let displayMaxSavedUserAlert = Notification.Name("displayMaxSavedUserAlert")
    static let returnToNativeLogin = Notification.Name("returnToNativeLogin")
    static let featureTourFinished = Notification.Name("featureTourFinished")
}
