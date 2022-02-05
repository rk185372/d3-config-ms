//
//  SwiftyBeaver+Level.swift
//  Pods
//
//  Created by Branden Smith on 11/29/18.
//

import Foundation
import SwiftyBeaver

extension SwiftyBeaver.Level: Comparable {
    public static func <(_ lhs: SwiftyBeaver.Level, _ rhs: SwiftyBeaver.Level) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func <=(_ lhs: SwiftyBeaver.Level, _ rhs: SwiftyBeaver.Level) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func >(_ lhs: SwiftyBeaver.Level, _ rhs: SwiftyBeaver.Level) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }

    public static func >=(_ lhs: SwiftyBeaver.Level, _ rhs: SwiftyBeaver.Level) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
}
