//
//  DictionaryDecoder.swift
//  Utilities
//
//  Created by Andrew Watt on 9/19/18.
//

import Foundation

/// Decodes Foundation-type dictionaries (such as those used by `JSONSerialization`).
///
/// This is a naive implementation that simply round-trips the dictionary into `Data` using
/// `JSONSerialization` and then decodes with `JSONDecoder`. It's not fast, but it works and is
/// well-tested. If there is a strong need for a faster implementation in the future, I suggest
/// taking a look at one based on the internals of `JSONDecoder` itself, such as this:
/// https://github.com/elegantchaos/DictionaryCoding
public final class DictionaryDecoder {
    public init() { }
    
    public func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let object = try JSONDecoder().decode(T.self, from: data)
        return object
    }
}
