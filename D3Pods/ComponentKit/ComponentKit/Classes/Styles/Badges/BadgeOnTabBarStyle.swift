//
//  BadgeOnTabBarStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/3/18.
//

import Foundation

public struct BadgeOnTabBarStyle: ComponentStyle, Decodable, Equatable {
    public let definition: BadgeStyleDefinition
    
    public init(definition: BadgeStyleDefinition) {
        self.definition = definition
    }
    
    public func style(component: UITabBarItem) {
        component.badgeColor = definition.backgroundColor.color
        
        var textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: definition.textColor.color
        ]
        
        if let fontSize = definition.textSize,
            //swiftlint:disable:next opening_brace
            let originalFont = component.badgeTextAttributes(for: .normal)?[NSAttributedString.Key.font] as? UIFont  {
            textAttributes[NSAttributedString.Key.font] = originalFont.withSize(fontSize)
        }
        
        component.setBadgeTextAttributes(textAttributes, for: .normal)
    }
}
