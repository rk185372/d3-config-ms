//
//  CenterIconStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 9/21/18.
//

import Foundation

public final class CenterIconStyleParser: StyleParser {
    public var handledKeys: [String] {
        return CenterIconViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(CenterIconViewStyle.self, from: json)

        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
