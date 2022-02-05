//
//  Dictionary+.swift
//  Utilities
//
//  Created by Andrew Watt on 7/26/18.
//

import Foundation

public extension Dictionary where Value: OptionalProtocol {
    /// Creates a copy of this dictionary with all non-`nil` values unboxed.
    ///
    /// - returns: a new dictionary without `nil` values
    func compactMapValues() -> [Key: Value.Wrapped] {
        return self.reduce(into: [:], { (result, element) in
            if let value = element.value.optional {
                result[element.key] = value
            }
        })
    }
}

public extension Dictionary {
    static func +=(_ lhs: inout [Key: Value], _ rhs: [Key: Value]) {
        lhs = rhs.reduce(into: lhs, { (result, keyValuePair) in
            result[keyValuePair.key] = keyValuePair.value
        })
    }
}
