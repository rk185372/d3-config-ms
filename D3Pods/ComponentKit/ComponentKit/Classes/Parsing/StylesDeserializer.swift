//
//  StylesDeserializer.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/8/18.
//

import Foundation

/// A class for deserializing ComponentStyles from StyleParsers.
public final class StylesDeserializer {
    private let styleParsers: [StyleParser]
    private let json: [String: Any]
    private let decoder = JSONDecoder()
    
    public init(styleParsers: [StyleParser], json: [String: Any]) {
        self.styleParsers = styleParsers
        self.json = json
    }
    
    /// Parses out style from all StyleParses and returns a Dictionary. This
    /// dictionary would be added to a ComponentStyleProvider to be accessed
    /// at runtime.
    ///
    /// - Returns: A dictionary of identifier keys and AnyComponentStyle values
    /// - Throws: StylesDeserializer.Error
    public func deserialize() throws -> [String: AnyComponentStyle] {
        var result: [String: AnyComponentStyle] = [:]
        
        for styleParser in styleParsers {
            for handledKey in styleParser.handledKeys {
                guard let objectJson = json[handledKey] as? [String: Any] else {
                    throw StylesDeserializer.Error.jsonKeyMissing(key: handledKey)
                }
                
                let data = try JSONSerialization.data(withJSONObject: objectJson as Any, options: [])
                
                let parseResult = try styleParser.parse(key: handledKey, json: data, decoder: decoder)
                result[parseResult.mapKey] = parseResult.mapValue
            }
        }
        
        return result
    }
}

extension StylesDeserializer {
    enum Error: Swift.Error {
        case jsonKeyMissing(key: String)
    }
}
