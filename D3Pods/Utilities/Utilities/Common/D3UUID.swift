//
//  D3UUID.swift
//  Utilities
//
//  Created by Chris Carranza on 6/19/18.
//

import Foundation

public final class D3UUID {
    private let userDefaults: UserDefaults
    
    public var uuidString: String {
        if let uuid: String = userDefaults.value(key: KeyStore.uuid) {
            return uuid
        } else {
            let uuid = UUID().uuidString
            userDefaults.set(value: uuid, key: KeyStore.uuid)
            return uuid
        }
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}
