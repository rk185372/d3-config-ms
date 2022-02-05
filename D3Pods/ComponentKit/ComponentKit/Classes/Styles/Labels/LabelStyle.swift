//
//  LabelStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/17/18.
//

import Foundation

public struct LabelStyle: ComponentStyle, Equatable, Decodable {
    public let textSize: CGFloat
    public let textColor: UIColor
    
    enum CodingKeys: CodingKey {
        case textSize
        case textColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        textSize = try container.decode(CGFloat.self, forKey: .textSize)
        textColor = try container.decode(UIColor.self, forKey: .textColor)
    }
    
    public func style(component: UILabelComponent) {
        component.updateOriginalFont(font: component.font.withSize(textSize))
        component.textColor = textColor
    }
}
