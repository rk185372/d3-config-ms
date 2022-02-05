//
//  SwitchStyleParser.swift
//  Accounts
//
//  Created by Chris Carranza on 6/13/18.
//

import Foundation

public final class SwitchStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public enum StyleKey: String, CaseIterable {
        case switchOnDefault
        case switchOnPrimary
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(SwitchStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
