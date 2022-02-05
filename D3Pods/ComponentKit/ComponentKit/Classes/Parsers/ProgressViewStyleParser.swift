//
//  ProgressViewStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/25/18.
//

import UIKit

public final class ProgressViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return ProgressViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ProgressViewStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
