//
//  StyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/8/18.
//

import Foundation

/// A protocol that defines an object that is capable of parsing styles to add to a ComponentStyleProvider
public protocol StyleParser {
    /// The keys that this parser can handle
    var handledKeys: [String] { get }
    
    /// Parse a given key with the provided json data and decoder
    ///
    /// - Parameters:
    ///   - key: The key being handled
    ///   - json: json data at the given key
    ///   - decoder: A Decoder to use for json Decoding
    /// - Returns: A StyleParseResult
    func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult
}

/// The results of parsing a ComponentStyle from a StyleParser
public struct StyleParseResult {
    public let mapKey: String
    public let mapValue: AnyComponentStyle
    
    public init<S: ComponentStyle>(mapKey: String, mapValue: S) {
        self.mapKey = mapKey
        self.mapValue = mapValue.anyComponentStyle()
    }
}

public enum StyleParserError: Error, CustomStringConvertible {
    case unhandledStyle(forKey: String)
    
    public var description: String {
        switch self {
        case .unhandledStyle(forKey: let key):
            return "Unhandled key: \(key)"
        }
    }
}
