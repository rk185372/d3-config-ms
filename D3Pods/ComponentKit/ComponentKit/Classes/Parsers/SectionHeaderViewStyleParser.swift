//
//  SectionHeaderViewStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/5/18.
//

import Foundation

public final class SectionHeaderViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return SectionHeaderViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(SectionHeaderViewStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
