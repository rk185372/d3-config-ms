//
//  CheckboxStyle.swift
//  Accounts
//
//  Created by Chris Carranza on 8/22/18.
//

import Foundation

public struct CheckboxStyle: ComponentStyle, Equatable, Decodable {
    public let checkmarkColor: UIColor
    public let innerColor: UIColor
    
    enum CodingKeys: CodingKey {
        case checkmarkColor
        case innerColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkmarkColor = try container.decode(UIColor.self, forKey: .checkmarkColor)
        innerColor = try container.decode(UIColor.self, forKey: .innerColor)
    }
    
    public func style(component: UICheckboxComponent) {
        component.secondaryCheckmarkTintColor = checkmarkColor
        component.secondaryTintColor = innerColor
        component.tintColor = innerColor
        component.boxType = .circle
        component.stateChangeAnimation = .fill
    }
}
