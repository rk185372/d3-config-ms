//
//  ViewStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/3/18.
//

import Foundation

public final class ViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return ViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ViewStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
