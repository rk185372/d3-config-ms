//
//  PrioritizedInitializer.swift
//  AppInitialization
//
//  Created by Chris Carranza on 8/31/18.
//

import Foundation
import Utilities
import RxSwift

/// An App Initializer that executes high priority tasks first,
/// then executes the remaining tasks concurrently.
final class PrioritizedInitializer: AppInitializer {
    var remainingTasks: [InitializationTask]
    
    init(tasks: [InitializationTask]) {
        self.remainingTasks = tasks
    }
    
    func initialize() -> Single<InitializationResult> {
        guard !remainingTasks.isEmpty else {
            return Single.just(.success)
        }
        
        return observableForTasks(highPriority: true)
            .flatMap { results in
                self.observableForTasks(highPriority: false)
                    .map { lowPriorityResults in
                        results + lowPriorityResults
                    }
            }
            .map(process(results:))
    }
    
    private func observableForTasks(highPriority: Bool) -> Single<[InitializationTaskResult]> {
        let tasks = remainingTasks.filter { $0.highPriority == highPriority }
        
        guard !tasks.isEmpty else {
            return Single.just([.success])
        }
        
        return Observable
            .zip(tasks.map { $0.run().asObservable() })
            .asSingle()
    }
}
