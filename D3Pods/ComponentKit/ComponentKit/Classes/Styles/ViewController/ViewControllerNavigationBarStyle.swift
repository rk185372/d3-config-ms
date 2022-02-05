//
//  ViewControllerNavigationBarStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/31/18.
//

import Foundation

public struct ViewControllerNavigationBarStyle: ComponentStyle, Decodable, Equatable {
    private let backgroundColor: UIColor
    private let tintColor: UIColor
    
    enum CodingKeys: CodingKey {
        case backgroundColor
        case tintColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try container.decode(UIColor.self, forKey: .backgroundColor)
        tintColor = try container.decode(UIColor.self, forKey: .tintColor)
    }
    
    public func style(component: UIViewControllerComponent) {
        component.navigationStyleItem.barTintColor = backgroundColor
        component.navigationStyleItem.tintColor = tintColor
        component.navigationStyleItem.isTranslucent = false
    }
    
    public func style(navigationController: UINavigationController) {
        navigationController.navigationBar.barTintColor = backgroundColor
        navigationController.navigationBar.tintColor = tintColor
        navigationController.navigationBar.isTranslucent = false
    }
}
