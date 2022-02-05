//
//  ConcurrentInitializer.swift
//  AppInitialization
//
//  Created by Chris Carranza on 8/31/18.
//

import Foundation
import Utilities
import RxSwift

/// An App Initializer that executes all initialization
/// tasks at the same time.
final class ConcurrentInitializer: AppInitializer {
    var remainingTasks: [InitializationTask]
    
    init(tasks: [InitializationTask]) {
        self.remainingTasks = tasks
    }
    
    func initialize() -> Single<InitializationResult> {
        guard !remainingTasks.isEmpty else {
            return Single.just(.success)
        }
        
        return Observable
            .zip(remainingTasks.map { $0.run().asObservable() })
            .map(process(results:))
            .asSingle()
    }
}
