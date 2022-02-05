//
//  UpgradeNotification.swift
//  Utilities
//
//  Created by Andrew Watt on 8/8/18.
//

import Foundation

public struct UpgradeNotification: Codable {
    public enum NotificationType: String, Codable {
        case optional = "OPTIONAL"
        case mandatory = "MANDATORY"
    }
    
    public let upgradeText: String
    public let titleText: String
    public let upgradeActionText: String
    public let cancelActionText: String
    public let notificationType: NotificationType
}
