//
//  Comparable+.swift
//  Utilities
//
//  Created by Andrew Watt on 8/9/18.
//

import Foundation

public extension Comparable {
    /// Returns this value or `value`, whichever is lesser
    func upperBounded(by value: Self) -> Self {
        return min(self, value)
    }
    
    /// Returns this value or `value`, whichever is greater
    func lowerBounded(by value: Self) -> Self {
        return max(self, value)
    }
    
    /// Returns this value clamped between `x` and `y`. The order of the parameters does not
    /// matter.
    func clampedBetween(_ x: Self, _ y: Self) -> Self {
        let lowerBound = min(x, y)
        let upperBound = max(x, y)
        return min(max(self, lowerBound), upperBound)
    }
}
