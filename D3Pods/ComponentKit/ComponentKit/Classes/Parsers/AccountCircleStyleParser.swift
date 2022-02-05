//
//  AccountCircleStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/4/18.
//

import Foundation

public final class AccountCircleStyleParser: StyleParser {
    public var handledKeys: [String] {
        return AccountCircleStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(AccountCircleStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
