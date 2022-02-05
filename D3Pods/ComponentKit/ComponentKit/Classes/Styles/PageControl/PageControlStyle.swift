//
//  PageControlStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 1/29/19.
//

import Foundation

public struct PageControlStyle: ComponentStyle, Equatable, Decodable {
    public let defaultColor: UIColor
    public let selectedColor: UIColor
    
    enum CodingKeys: CodingKey {
        case defaultColor
        case selectedColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultColor = try container.decode(UIColor.self, forKey: .defaultColor)
        selectedColor = try container.decode(UIColor.self, forKey: .selectedColor)
    }
    
    public func style(component: UIPageControlComponent) {
        component.pageIndicatorTintColor = defaultColor
        component.currentPageIndicatorTintColor = selectedColor
    }
}
