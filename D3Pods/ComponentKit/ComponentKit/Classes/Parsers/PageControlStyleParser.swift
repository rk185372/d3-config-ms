//
//  PageControlStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 1/29/19.
//

import Foundation

public final class PageControlStyleParser: StyleParser {
    public var handledKeys: [String] {
        return PageControlStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(PageControlStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
