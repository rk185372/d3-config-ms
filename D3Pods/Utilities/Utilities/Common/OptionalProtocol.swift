//
//  OptionalProtocol.swift
//  Utilities
//
//  Created by Andrew Watt on 7/25/18.
//

import Foundation

// Shamelessly stolen from:
// https://github.com/ReactiveCocoa/ReactiveSwift/blob/master/Sources/Optional.swift

/// An optional protocol for use in type constraints.
public protocol OptionalProtocol {
    /// The type contained in the optional.
    associatedtype Wrapped
    
    init(reconstructing value: Wrapped?)
    
    /// Extracts an optional from the receiver.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? {
        return self
    }
    
    public init(reconstructing value: Wrapped?) {
        self = value
    }
}
