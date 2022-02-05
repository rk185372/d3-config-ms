//
//  NilArgumentHandler.swift
//  UITestingHelper
//
//  Created by Chris Carranza on 8/7/17.
//

import Foundation

public final class NilArgumentHandler: ArgumentHandler {
    
    public static let handlerIdentifier: String = ""
    
    public static var argumentKeys: [String] = []
    
    public init() {}
    
    public func handle(_ arguments: inout IndexingIterator<[String]>) throws {
        
    }
}
