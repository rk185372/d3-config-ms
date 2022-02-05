//
//  TabBarControllerStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 8/30/18.
//

import Foundation

public final class TabBarControllerStyleParser: StyleParser {
    public var handledKeys: [String] {
        return TabBarControllerStyleKey.allCases.map { $0.rawValue }
    }

    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(TabBarControllerStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
