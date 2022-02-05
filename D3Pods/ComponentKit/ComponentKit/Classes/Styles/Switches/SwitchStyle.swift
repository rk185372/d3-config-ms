//
//  SwitchStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 6/13/18.
//

import Foundation

public struct SwitchStyle: ComponentStyle, Equatable, Decodable {
    public let outlineColor: UIColor
    public let onTintColor: UIColor
    public let thumbTintColor: UIColor

    enum CodingKeys: CodingKey {
        case outlineColor
        case onTintColor
        case thumbTintColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        outlineColor = try container.decode(UIColor.self, forKey: .outlineColor)
        onTintColor = try container.decode(UIColor.self, forKey: .onTintColor)
        thumbTintColor = try container.decode(UIColor.self, forKey: .thumbTintColor)
    }
    
    public func style(component: UISwitchComponent) {
        component.tintColor = outlineColor
        component.onTintColor = onTintColor
        component.thumbTintColor = thumbTintColor
    }
}
