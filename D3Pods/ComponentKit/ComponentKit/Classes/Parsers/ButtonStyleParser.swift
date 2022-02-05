//
//  ButtonStyleParser.swift
//  Accounts
//
//  Created by Chris Carranza on 5/10/18.
//

import Foundation

public final class ButtonStyleParser: StyleParser {
    public var handledKeys: [String] {
        return ButtonStyleKey.allCases.map { $0.rawValue }
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ButtonStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
