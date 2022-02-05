//
//  TableViewStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 11/14/18.
//

import Foundation

public final class TableViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return TableViewStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(TableViewStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
