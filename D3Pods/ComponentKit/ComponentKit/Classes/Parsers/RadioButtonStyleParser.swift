//
//  RadioButtonStyleParser.swift
//  Authentication
//
//  Created by Chris Carranza on 7/12/18.
//

import Foundation

public final class RadioButtonStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public enum StyleKey: String, CaseIterable {
        case radioButtonCta
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(RadioButtonStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
