//
//  CheckboxStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 8/22/18.
//

import Foundation

public final class CheckboxStyleParser: StyleParser {
    public var handledKeys: [String] {
        return CheckboxStyleKey.allCases.map { $0.rawValue }
    }

    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(CheckboxStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
