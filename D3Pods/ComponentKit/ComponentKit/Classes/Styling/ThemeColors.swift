//
//  ThemeColors.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 2/24/21.
//

import Foundation

public struct ThemeColors: Decodable {
    private struct ThemeColor: Decodable {
        let background: DecodableColor
    }
    private var colors: [ColorKey: UIColor] = [:]

    public enum ColorKey: String, CodingKey, CaseIterable {
        case backgroundPrimary
        case backgroundSecondary
    }

    public func get(_ colorKey: ColorKey) -> UIColor {
        return colors[colorKey] ?? .black
    }

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorKey.self)
        try ColorKey.allCases.forEach {
            colors[$0] = try container.decode(ThemeColor.self, forKey: $0).background.color
        }
    }
}
