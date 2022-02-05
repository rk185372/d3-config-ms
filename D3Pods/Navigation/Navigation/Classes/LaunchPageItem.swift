//
//  LaunchPageMenuItem.swift
//  Navigation
//
//  Created by Andrew Watt on 7/24/18.
//

import Foundation

public struct LaunchPageItem {
    public var name: String
    public var type: LaunchPageItemType
    
    public init(name: String, type: LaunchPageItemType) {
        self.name = name
        self.type = type
    }
}

public enum LaunchPageItemType {
    case locations
    case webView(url: URL)
    case phone(number: String)
}
