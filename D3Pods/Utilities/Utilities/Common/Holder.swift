//
//  Holder.swift
//  Utilities
//
//  Created by Andrew Watt on 7/10/18.
//

import Foundation

/// A generic, non-reactive box to act as a placeholder for values that are guaranteed by the
/// application to exist at some point.
public final class Holder<T> {
    public var value: T?
    
    public init(initialValue: T? = nil) {
        value = initialValue
    }
}
