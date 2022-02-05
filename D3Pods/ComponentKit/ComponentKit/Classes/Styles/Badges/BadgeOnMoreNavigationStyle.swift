//
//  BadgeOnMoreNavigationStyle.swift
//  ComponentKit
//
//  Created by Jose Torres on 9/29/20.
//

import Foundation

public struct BadgeOnMoreNavigationStyle: ComponentStyle, Decodable, Equatable {
    public let definition: BadgeStyleDefinition
    
    public init(definition: BadgeStyleDefinition) {
        self.definition = definition
    }
    
    public func style(component: BadgeOnMoreView) {
        component.view.backgroundColor = definition.backgroundColor.color
        component.textLabel.textColor = definition.textColor.color
        if let size = definition.textSize {
            component.textLabel.font = component.textLabel.font.withSize(size)
        }
    }
}
