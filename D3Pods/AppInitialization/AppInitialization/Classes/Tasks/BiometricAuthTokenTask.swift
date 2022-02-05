//
//  BiometricAuthTokenTask.swift
//  AppInitialization
//
//  Created by Chris Carranza on 10/22/18.
//

import Foundation
import RxSwift
import RxRelay
import Utilities
import Biometrics

public final class BiometricAuthTokenTask: InitializationTask {
    private let biometricsHelper: BiometricsHelper
    
    public init(biometricsHelper: BiometricsHelper) {
        self.biometricsHelper = biometricsHelper
    }
    
    public func run() -> Single<InitializationTaskResult> {
        return biometricsHelper
            .updateServerTokenStatus()
            .map { _ in
                return InitializationTaskResult.success
            }
            .catchErrorJustReturn(.success)
    }
}
