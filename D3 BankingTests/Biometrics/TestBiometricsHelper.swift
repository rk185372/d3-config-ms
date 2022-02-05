//
//  TestBiometricsHelper.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 10/5/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
@testable import Biometrics
import RxSwift
import RxRelay

final class TestBiometricsHelper: BiometricsHelper {

    var biometricAuthEnabled: Bool
    
    var biometricAuthNeedsEnabled: Bool
    
    var domainStateChanged: Bool
    
    var supportedBiometricType: SupportedBiometricType
    
    init(supportedBiometricType: SupportedBiometricType,
         domainStateChanged: Bool,
         biometricAuthEnabled: Bool,
         biometricAuthNeedsEnabled: Bool) {
        self.supportedBiometricType = supportedBiometricType
        self.domainStateChanged = domainStateChanged
        self.biometricAuthEnabled = biometricAuthEnabled
        self.biometricAuthNeedsEnabled = biometricAuthNeedsEnabled
    }

    func tokenExists() -> Bool {
        return true
    }

    func updateServerTokenStatus() -> Single<Bool> {
        return Single.create { observer in
            observer(.success(true))
            return Disposables.create()
        }
    }
    
    func optInBiometricAuth() -> Completable {
        return Completable.empty()
    }
    
    func optOutBiometricAuth() -> Completable {
        return Completable.empty()
    }
    
    func authenticate() -> Completable {
        return Completable.empty()
    }

    func retrieveToken() -> Single<String> {
        return Single.create { observer in
            observer(.success("theToken"))

            return Disposables.create()
        }
    }


    func updateToken(token: String) throws {}

    func removeToken() throws {}
}
