//
//  StartupTask.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/8/18.
//

import Foundation
import CompanyAttributes
import Localization
import Logging
import Utilities
import RxSwift

public final class StartupTask: InitializationTask {
    private let service: AppInitializationService
    private let startupHolder: StartupHolder
    
    public init(service: AppInitializationService, startupHolder: StartupHolder) {
        self.service = service
        self.startupHolder = startupHolder
    }
    
    public func run() -> Single<InitializationTaskResult> {
        return service.getStartup()
            .map { (startup) -> InitializationTaskResult in
                self.startupHolder.decodedStartup = startup
                return .success
            }
            .catchError { (error) in
                log.error("Startup task error: \(error)", context: error)
                
                return Single.just(.failure(reason: error))
            }
    }
}
