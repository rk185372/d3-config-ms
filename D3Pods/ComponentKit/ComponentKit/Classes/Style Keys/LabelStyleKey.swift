//
//  LabelStyleKey.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/1/18.
//

import Foundation

public struct LabelStyleKey: Hashable, CaseIterable {
    public enum Size: String, CaseIterable {
        case h1
        case h2
        case h3
        case h4
        case h5
        case largeText
    }
    public enum Color: String, CaseIterable {
        case cta = "Cta"
        case error = "Error"
        case onCta = "OnCta"
        case onDefault = "OnDefault"
        case onDefaultLight = "OnDefaultLight"
        case onLogin = "OnLogin"
        case onPrimary = "OnPrimary"
        case onSecondary = "OnSecondary"
    }
    
    public static let allCases: Set<LabelStyleKey> = Set(
        Size.allCases.flatMap { size in
            return Color.allCases.map { color in
                return LabelStyleKey(size: size, color: color)
            }
        }
    )
    
    public let size: Size
    public let color: Color
    
    public var keyValue: String {
        return "\(size.rawValue)\(color.rawValue)"
    }
    
    public init(size: Size, color: Color) {
        self.size = size
        self.color = color
    }
}
