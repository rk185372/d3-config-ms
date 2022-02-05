//
//  UpgradeCheckTask.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/8/18.
//

import Foundation
import Logging
import RxSwift
import Utilities

public final class UpgradeCheckTask: InitializationTask {
    private let service: AppInitializationService
    public let highPriority: Bool = true
    
    public init(service: AppInitializationService) {
        self.service = service
    }
    
    public func run() -> Single<InitializationTaskResult> {
        return service.checkForUpgrades()
            .map { (notification) -> InitializationTaskResult in
                if let notification = notification {
                    return .userInteractionRequired(interaction: .upgrade(notification: notification))
                }
                return .success
            }
            .catchError { (error) in
                log.error("App upgrade check error: \(error)", context: error)

                return Single.just(.failure(reason: error))
            }
    }
}
