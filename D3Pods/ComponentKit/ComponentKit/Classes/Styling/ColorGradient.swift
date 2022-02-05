//
//  ColorGradient.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import Foundation

public struct ColorGradient {
    public var startColor: UIColor
    public var stopColor: UIColor
    
    var cgColors: [CGColor] {
        return [startColor.cgColor, stopColor.cgColor]
    }
}

extension ColorGradient: Equatable {
    public static func == (lhs: ColorGradient, rhs: ColorGradient) -> Bool {
        return lhs.startColor == rhs.startColor && lhs.stopColor == rhs.stopColor
    }
}
