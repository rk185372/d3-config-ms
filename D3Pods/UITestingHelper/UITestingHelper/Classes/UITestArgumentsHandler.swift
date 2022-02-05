//
//  UITestArgumentsHandler.swift
//  UITestingHelper
//
//  Created by Chris Carranza on 8/4/17.
//

import Foundation

public class UITestArgumentsHandler {
    private let window: UIWindow
    private let arguments: [String]
    
    enum Error: Swift.Error {
        case missingArgument
        case invalidArgument
    }
    
    public init(window: UIWindow, arguments: [String]) {
        self.window = window
        self.arguments = arguments
    }
    
    public func processArguments() throws {
        var args = arguments.makeIterator()
        while let arg = args.next() {
            let handler = handlerForArgument(arg)
            do {
                try handler.handle(&args)
            } catch Error.missingArgument {
                fatalError("Missing")
            } catch Error.invalidArgument {
                fatalError("Invalid")
            }
        }
    }
    
    private func handlerForArgument(_ argument: String) -> ArgumentHandler {
        switch argument {
        case ScreenArgumentHandler.handlerIdentifier:
            return ScreenArgumentHandler(window: window)
        default:
            return NilArgumentHandler()
        }
    }
    
}
