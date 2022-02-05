//
//  BadgeStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/3/18.
//

import Foundation

public final class BadgeStyleParser: StyleParser {
    public var handledKeys: [String] {
        return BadgeStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let definition = try decoder.decode(BadgeStyleDefinition.self, from: json)
        
        guard let handledKey = BadgeStyleKey(rawValue: key) else {
            throw StyleParserError.unhandledStyle(forKey: key)
        }
        
        switch handledKey {
        case .badgeOnStackedMenu:
            return StyleParseResult(mapKey: key, mapValue: BadgeViewStyle(definition: definition))
        case .badgeOnTabBar:
            return StyleParseResult(mapKey: key, mapValue: BadgeOnTabBarStyle(definition: definition))
        case .badgeOnMoreNavigation:
            return StyleParseResult(mapKey: key, mapValue: BadgeOnMoreNavigationStyle(definition: definition))
        }
    }
    
}
