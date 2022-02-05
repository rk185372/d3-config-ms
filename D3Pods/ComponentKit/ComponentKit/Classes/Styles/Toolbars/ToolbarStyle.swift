//
//  ToolbarStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/31/18.
//

import Foundation

public struct ToolbarStyle: ComponentStyle, Equatable, Decodable {
    public let backgroundColor: DecodableColor
    public let color: DecodableColor
    
    public func style(component: UIToolbarComponent) {
        component.barTintColor = backgroundColor.color
        component.tintColor = color.color
    }
}
