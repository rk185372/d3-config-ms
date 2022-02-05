//
//  Decoded.swift
//  Utilities
//
//  Created by Andrew Watt on 7/6/18.
//

import Foundation

/// Pairs a decoded value with the source data from which it was decoded.
public struct Decoded<Value, Source> {
    public var value: Value
    public var source: Source
    
    public init(value: Value, source: Source) {
        self.value = value
        self.source = source
    }
}
