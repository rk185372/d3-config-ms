//
//  PostAuthFlowController.swift
//  PostAuthFlowController
//
//  Created by Chris Carranza on 8/1/18.
//

import Foundation

public protocol PostAuthFlowController: class {
    func advance()
    func cancel()
}
