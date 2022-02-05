//
//  StackedMenuViewStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/20/18.
//

import Foundation

public final class StackedMenuViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StackedMenuViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(StackedMenuViewStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
