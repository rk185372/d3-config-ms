//
//  NumberFormatter+D3.swift
//  D3 Banking
//
//  Created by Chris Carranza on 6/5/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation

/// Any type that can be converted to an NSNumber
public protocol NSNumberConvertible {
    func asNSNumber() -> NSNumber
}

extension NSNumber: NSNumberConvertible {
    public func asNSNumber() -> NSNumber {
        return self
    }
}

extension Double: NSNumberConvertible {
    public func asNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int: NSNumberConvertible {
    public func asNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Float: NSNumberConvertible {
    public func asNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension NumberFormatter {
    
    /// Returns a string containing the formatted value of the provided number object.
    ///
    /// - Parameter number: An NSNumberConvertible object that is parsed to create the returned string object.
    /// - Returns: A string containing the formatted value of number using the receiver’s current settings.
    public final func string<T: NSNumberConvertible>(from number: T) -> String? {
        return string(from: number.asNSNumber())
    }
}

extension NumberFormatter {

    /// Returns a `NumberFormatter` configured to deal with currency. The default
    /// currency code for the is formatter is "USD".
    ///
    /// - Parameter currencyCode: The currency code for the number formatter.
    /// - Returns: A currency formatter.
    public static func currencyFormatter(currencyCode: String = "USD") -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.currencyCode = currencyCode
        formatter.numberStyle = .currency
        formatter.allowsFloats = true

        return formatter
    }
}
