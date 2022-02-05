//
//  FloatConvertible.swift
//  Analytics
//
//  Created by Chris Carranza on 10/31/17.
//

import Foundation

public protocol FloatConvertible {
    func toFloat() -> Float
}

extension Float: FloatConvertible {
    public func toFloat() -> Float {
        return self
    }
}

extension CGFloat: FloatConvertible {
    public func toFloat() -> Float {
        return Float(self)
    }
}

extension Int: FloatConvertible {
    public func toFloat() -> Float {
        return Float(self)
    }
}

extension Double: FloatConvertible {
    public func toFloat() -> Float {
        return Float(self)
    }
}
