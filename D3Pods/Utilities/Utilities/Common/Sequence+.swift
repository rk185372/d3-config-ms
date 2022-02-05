//
//  Sequence+.swift
//  Pods
//
//  Created by Chris Carranza on 5/18/17.
//
//

import Foundation

public extension Sequence where Iterator.Element: Hashable {
    /// Creates an array of unique elements.
    var uniqueElements: [Iterator.Element] {
        return Array( Set(self) )
    }
}
public extension Sequence where Iterator.Element: Equatable {
    /// Creates an array of unique elements.
    var uniqueElements: [Iterator.Element] {
        return self.reduce([]) { uniqueElements, element in
            uniqueElements.contains(element) ? uniqueElements : uniqueElements + [element]
        }
    }
}

public extension Sequence {
    /// Scan is a high-order function similar to reduce, but returns a sequence containing all intermediary values.
    ///
    /// For example:
    ///
    ///     (1..<6).scan(0, +) // [1, 3, 6, 10, 15]
    ///
    /// - Complexity: O(n)
    func scan<Result>(initial: Result, nextPartialResult: (Result, Element) throws -> Result) rethrows -> [Result] {
        var last = initial
        return try map { element in
            last = try nextPartialResult(last, element)
            return last
        }
    }

    /// Applies the given transform to each element in this sequence, and creates a dictionary that
    /// maps the transform results to the elements that produced each result.
    ///
    /// If more than one element produces the same transform value, the first one will be used.
    ///
    /// - parameter transform: the transform to apply to each element to produce its dictionary key
    /// - returns: a dictionary mapping from transform results to elements
    func flatIndex<K: Hashable>(_ transform: (Self.Iterator.Element) throws -> K) rethrows -> [K: Self.Iterator.Element] {
        return try self.reduce(into: [:]) { (indexed, element) in
            let key = try transform(element)
            if indexed[key] == nil {
                indexed[key] = element
            }
        }
    }
}

public extension Sequence where Iterator.Element: OptionalProtocol {
    /// Returns a new array with all nil elements removed.
    func compacted() -> [Iterator.Element.Wrapped] {
        return compactMap { $0.optional }
    }
}
