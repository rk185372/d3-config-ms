//
//  DecodableColor.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import UIKit

public struct DecodableColor: Decodable, Equatable {
    public let color: UIColor
    
    public init(from decoder: Decoder) throws {
        self.color = try decoder.singleValueContainer().decode(UIColor.self)
    }
}
