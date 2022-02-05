//
//  TextFieldStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/5/18.
//

import Foundation

public final class TextFieldStyleParser: StyleParser {
    public var handledKeys: [String] {
        return TextFieldStyleKey.allCases.map { $0.rawValue }
    }
    
    public init () { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(TextFieldStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
