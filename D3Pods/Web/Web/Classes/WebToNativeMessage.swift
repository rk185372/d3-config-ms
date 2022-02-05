//
//  WebToNativeMessage.swift
//  Web
//
//  Created by Andrew Watt on 10/11/18.
//

import Foundation

enum WebToNativeMessage: String, CaseIterable {
    case closeZelleModal
    case csrf
    case device
    case download
    case extensions
    case getLocalization
    case getSnapshotToken
    case getZelleContact
    case getZelleProfileQRCodes
    case getDeviceContacts
    case hasPromptedForContacts
    case hasFaceId
    case inAppRatingEvent
    case isFingerprintAllowed
    case log
    case logout
    case maintenance
    case openHtmlDocument
    case openURLExternal = "openUrlExternal"
    case openURL = "openUrl"
    case openZelleModal
    case openZelleScanQRCodeModal
    case openZelleViewQRCodeModal
    case openCardControls
    case sectionRequiresUpdate
    case selectProfile
    case session
    case startup
    case storeSnapshotToken
    case theme
    case toggleFingerprint
    case updateBadge
    case updateUserProfile
    case url
    case allowTabSwitch
}
