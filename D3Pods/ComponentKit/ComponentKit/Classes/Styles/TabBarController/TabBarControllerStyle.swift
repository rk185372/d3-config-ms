//
//  TabBarControllerStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 8/30/18.
//

import Foundation

public struct TabBarControllerStyle: ComponentStyle, Equatable, Decodable {
    private let backgroundColor: UIColor
    private let itemColor: UIColor
    private let unselectedItemColor: UIColor
    private let moreControllerTintColor: UIColor?

    enum CodingKeys: CodingKey {
        case backgroundColor
        case itemColor
        case unselectedItemColor
        case badgeColor
        case badgeTextColor
        case moreTintColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try container.decode(UIColor.self, forKey: .backgroundColor)
        itemColor = try container.decode(UIColor.self, forKey: .itemColor)
        unselectedItemColor = try container.decode(UIColor.self, forKey: .unselectedItemColor)
        moreControllerTintColor = try? container.decode(UIColor.self, forKey: .moreTintColor)
    }
    
    public func style(component: UITabBarControllerComponent) {
        component.tabBar.barTintColor = backgroundColor
        component.tabBar.isTranslucent = false
        component.tabBar.tintColor = itemColor
        component.tabBar.unselectedItemTintColor = unselectedItemColor
        component.view.tintColor = moreControllerTintColor ?? backgroundColor
    }
}
