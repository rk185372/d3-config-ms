//
//  LabelStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/17/18.
//

import Foundation

public final class LabelStyleParser: StyleParser {
    public var handledKeys: [String] {
        return LabelStyleKey.allCases.map { $0.keyValue }
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let labelStyle = try decoder.decode(LabelStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: labelStyle)
    }
}
