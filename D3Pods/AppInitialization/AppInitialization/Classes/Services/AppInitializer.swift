//
//  AppInitializer.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/7/18.
//

import Foundation
import CompanyAttributes
import Utilities
import Localization
import RxSwift

protocol AppInitializer: class {
    var remainingTasks: [InitializationTask] { get set }
    func initialize() -> Single<InitializationResult>
}

public enum InitializationResult {
    case failure
    case offline
    case success
    case userInteractionRequired(interaction: InitializationUserInteraction)
}

extension AppInitializer {
    func process(results: [InitializationTaskResult]) -> InitializationResult {
        // Save tasks that failed for retry
        remainingTasks = zip(remainingTasks, results)
            .filter { (_, result) in
                if case .failure = result {
                    return true
                }
                return false
            }
            .map { (task, _) in task }
        
        // First user-interaction-required task wins
        for result in results {
            if case let .userInteractionRequired(interaction) = result {
                return .userInteractionRequired(interaction: interaction)
            }
        }
        
        // Then check if we had any offline errors
        for result in results {
            if case let .failure(reason) = result, let urlError = reason as? URLError, urlError.code == .notConnectedToInternet {
                return .offline
            }
        }
        
        if remainingTasks.isEmpty {
            return .success
        } else {
            return .failure
        }
    }
}
