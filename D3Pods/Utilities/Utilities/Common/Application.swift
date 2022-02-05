//
//  Application.swift
//  Utilities
//
//  Created by Andrew Watt on 6/29/18.
//

import Foundation

public struct Application {
    public static func current() -> Application {
        return Application(
            appVersion: Bundle.main.string(forBundleKey: .CFBundleShortVersionString),
            buildVersion: Bundle.main.string(forBundleKey: .CFBundleVersion)
        )
    }

    public var appVersion: String
    public var buildVersion: String
}

extension Bundle {
    func string(forBundleKey key: CoreFoundationBundleKey) -> String {
        return self.stringValueForKey(key.rawValue) ?? ""
    }
}

enum CoreFoundationBundleKey: String {
    case CFBundleAllowMixedLocalizations
    case CFBundleDevelopmentRegion
    case CFBundleDisplayName
    case CFBundleDocumentTypes
    case CFBundleExecutable
    case CFBundleIconFile
    case CFBundleIconFiles
    case CFBundleIcons
    case CFBundleIdentifier
    case CFBundleInfoDictionaryVersion
    case CFBundleLocalizations
    case CFBundleName
    case CFBundlePackageType
    case CFBundleShortVersionString
    case CFBundleSignature
    case CFBundleSpokenName
    case CFBundleURLTypes
    case CFBundleVersion
}
