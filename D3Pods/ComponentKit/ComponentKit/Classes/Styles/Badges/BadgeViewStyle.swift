//
//  BadgeViewStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/3/18.
//

import Foundation

public struct BadgeViewStyle: ComponentStyle {
    public let definition: BadgeStyleDefinition
    
    public init(definition: BadgeStyleDefinition) {
        self.definition = definition
    }
    
    public func style(component: BadgeView) {
        component.badgeColor = definition.backgroundColor.color
        component.textColor = definition.textColor.color
        if let fontSize = definition.textSize {
            component.updateOriginalFont(font: component.font.withSize(fontSize))
        }
    }
}
