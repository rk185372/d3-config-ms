//
//  InitializationTaskResult.swift
//  Utilities
//
//  Created by Andrew Watt on 8/8/18.
//

import Foundation

public enum InitializationTaskResult {
    case success
    case failure(reason: Error)
    case userInteractionRequired(interaction: InitializationUserInteraction)
}

public enum InitializationUserInteraction {
    case upgrade(notification: UpgradeNotification)
}
