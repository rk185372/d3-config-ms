//
//  Log.swift
//  NavigationComponentBuilder
//
//  Created by Branden Smith on 11/6/19.
//

import Darwin
import Foundation

public enum Log {
    public enum Level: Int {
        case errors
        case warnings
        case info
        case verbose
    }

    public static var level: Level = .info

    public static func error(_ message: Any) {
        log(level: .errors, "error: \(message)")
    }

    public static func warning(_ message: Any) {
        log(level: .warnings, "warning: \(message)")
    }

    public static func verbose(_ message: Any) {
        log(level: .verbose, message)
    }

    public static func info(_ message: Any) {
        log(level: .info, message)
    }

    private static func log(level logLevel: Level, _ message: Any) {
        guard logLevel.rawValue <= Log.level.rawValue else { return }
        print(message)
    }
}

extension String: Error {}
