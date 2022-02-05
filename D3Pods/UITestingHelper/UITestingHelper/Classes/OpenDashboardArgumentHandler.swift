//
//  OpenDashboardArgumentHandler.swift
//  UITestingHelper
//
//  Created by Chris Carranza on 8/7/17.
//

import Foundation

public final class OpenDashboardArgumentHandler: ArgumentHandler {
    public static let handlerIdentifier: String = "--openDashboard"
    public static var argumentKeys: [String] = []
    
    private let window: UIWindow
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func handle(_ arguments: inout IndexingIterator<[String]>) throws {
        
    }
}
