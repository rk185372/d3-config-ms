//
//  AnalyticsEvent.swift
//  Analytics
//
//  Created by Chris Carranza on 10/30/17.
//

import Foundation

public struct AnalyticsEvent {
    public let category: String
    public let action: String
    public let name: String
    public let value: FloatConvertible?
}

extension AnalyticsEvent {
    public struct Action {
        let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
    
    public init(category: String, action: AnalyticsEvent.Action, name: String, value: FloatConvertible? = nil) {
        self.category = category
        self.action = action.name
        self.name = name
        self.value = value
    }
}

extension AnalyticsEvent.Action {
    public static let click = AnalyticsEvent.Action(name: "Click")
    public static let toggle = AnalyticsEvent.Action(name: "Toggle")
    public static let result = AnalyticsEvent.Action(name: "Result")
    public static let autoPrompt = AnalyticsEvent.Action(name: "AutoPrompt")
}

extension AnalyticsEvent: Equatable {
    public static func ==(_ lhs: AnalyticsEvent, _ rhs: AnalyticsEvent) -> Bool {
        func equalValues(for lhs: AnalyticsEvent, and rhs: AnalyticsEvent) -> Bool {
            switch (lhs.value, rhs.value) {
            case (nil, nil):
                return true
            case (.some(let left), .some(let right)):
                return left.toFloat() == right.toFloat()
            default:
                return false
            }
        }

        return lhs.category == rhs.category
            && lhs.action == rhs.action
            && lhs.name == rhs.name
            && equalValues(for: lhs, and: rhs)

    }
}

extension AnalyticsEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(action)
        hasher.combine(name)
        hasher.combine(value?.toFloat())
    }
}

extension AnalyticsEvent: CustomStringConvertible {
    public var description: String {
        var desc = "AnalyticsEvent("
            + "category: \(category), "
            + "action: \(action), "
            + "name: \(name), "
            + "value: "

        if let val = value?.toFloat() {
            desc += "\(String(val)))"
        } else {
            desc += "nil)"
        }

        return desc
    }
}
