//
//  InitializationTask.swift
//  Utilities
//
//  Created by Andrew Watt on 8/16/2018.
//

import Foundation
import RxSwift

public protocol InitializationTask {
    var highPriority: Bool { get }
    func run() -> Single<InitializationTaskResult>
}

public extension InitializationTask {
    var highPriority: Bool {
        return false
    }
}
