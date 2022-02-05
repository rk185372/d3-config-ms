//
//  UserDataMigrationTask.swift
//  AppInitialization
//
//  Created by Pablo Pellegrino on 24/09/2021.
//

import Foundation
import Utilities
import RxSwift

public final class UserDataMigrationTask: InitializationTask {
    private let userDefaults: UserDefaults
    private let authUserStore: AuthUserStore
    
    private enum OldKeys: String, KeyStoreConvertible {
        var key: String { return rawValue }
        
        case username = "d3UserName"
    }
    
    public init(userDefaults: UserDefaults, authUserStore: AuthUserStore) {
        self.userDefaults = userDefaults
        self.authUserStore = authUserStore
    }
    
    public func run() -> Single<InitializationTaskResult> {
        if let username: String = userDefaults.value(key: OldKeys.username),
           authUserStore.userData(for: username) == nil {
            let userData = AuthUserStore.UserData(username: username,
                                                  isTemporary: false,
                                                  isPersonalAccount: true)
            authUserStore.saveUserData(userData)
            authUserStore.setCurrentUser(userData: userData)
            userDefaults.removeValue(key: OldKeys.username)
        }
        return Single.just(.success)
    }
}
