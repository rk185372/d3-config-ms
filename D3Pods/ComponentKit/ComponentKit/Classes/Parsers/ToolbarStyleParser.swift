//
//  ToolbarStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/31/18.
//

import Foundation

public final class ToolbarStyleParser: StyleParser {
    public var handledKeys: [String] {
        return ToolbarStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ToolbarStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
