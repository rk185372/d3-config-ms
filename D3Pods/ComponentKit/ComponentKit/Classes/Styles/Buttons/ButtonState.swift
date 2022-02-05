//
//  ButtonState.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/4/18.
//

import Foundation

public struct ButtonState: Equatable, Decodable {
    public let textColor: UIColor
    public let background: ComponentBackground
    public let borderColor: UIColor?
    
    enum CodingKeys: CodingKey {
        case textColor
        case background
        case borderColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        textColor = try container.decode(UIColor.self, forKey: .textColor)
        background = try container.decode(ComponentBackground.self, forKey: .background)
        borderColor = try container.decodeIfPresent(UIColor.self, forKey: .borderColor)
    }
}
