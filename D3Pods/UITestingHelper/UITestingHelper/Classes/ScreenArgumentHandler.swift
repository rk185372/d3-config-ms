//
//  ScreenArgumentHandler.swift
//  UITestingHelper
//
//  Created by Chris Carranza on 8/7/17.
//

import Foundation

public protocol ArgumentHandler {
    static var handlerIdentifier: String { get }
    static var argumentKeys: [String] { get }
    func handle(_ arguments: inout IndexingIterator<[String]>) throws
    
    static func produceLaunchArguments() -> [String]
}

public extension ArgumentHandler {
    public static func produceLaunchArguments() -> [String] {
        return [Self.handlerIdentifier] + Self.argumentKeys
    }
}

public final class ScreenArgumentHandler: ArgumentHandler {
    public static let handlerIdentifier: String = "--launchScreen"
    public let window: UIWindow
    
    public static var argumentKeys: [String] = []
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func handle(_ arguments: inout IndexingIterator<[String]>) throws {
        print(arguments)
    }
    
}
