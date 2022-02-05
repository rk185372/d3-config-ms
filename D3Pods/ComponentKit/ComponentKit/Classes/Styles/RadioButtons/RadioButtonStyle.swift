//
//  RadioButtonStyle.swift
//  Authentication
//
//  Created by Chris Carranza on 7/12/18.
//

import Foundation

public struct RadioButtonStyle: ComponentStyle, Equatable, Decodable {
    public let outlineColor: UIColor
    public let innerColor: UIColor
    
    enum CodingKeys: CodingKey {
        case outlineColor
        case innerColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        outlineColor = try container.decode(UIColor.self, forKey: .outlineColor)
        innerColor = try container.decode(UIColor.self, forKey: .innerColor)
    }
    
    public func style(component: UIRadioButtonComponent) {
        component.outerCircleColor = outlineColor
        component.innerCircleCircleColor = innerColor
    }
}
