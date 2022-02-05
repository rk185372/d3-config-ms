//
//  ComponentBackground.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import Foundation

public enum ComponentBackground: Decodable {
    case none
    case solid(color: UIColor)
    case gradient(gradient: ColorGradient)
    
    enum GradientKey: CodingKey {
        case startColor
        case stopColor
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: GradientKey.self) {
            let startColor = try container.decode(UIColor.self, forKey: .startColor)
            let stopColor = try container.decode(UIColor.self, forKey: .stopColor)
            self = .gradient(gradient: ColorGradient(startColor: startColor, stopColor: stopColor))
        } else if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .none
            } else {
                self = .solid(color: try container.decode(UIColor.self))
            }
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid component background")
            throw DecodingError.dataCorrupted(context)
        }
    }
}

extension ComponentBackground: Equatable {
    public static func == (lhs: ComponentBackground, rhs: ComponentBackground) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.solid(let leftColor), .solid(let rightColor)):
            return leftColor == rightColor
        case (.gradient(let leftGradient), .gradient(let rightGradient)):
            return leftGradient == rightGradient
        default:
            return false
        }
    }
}
