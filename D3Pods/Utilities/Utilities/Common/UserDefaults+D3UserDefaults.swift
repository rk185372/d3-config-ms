//
//  UserDefaults+D3UserDefaults.swift
//  Pods
//
//  Created by Chris Carranza on 12/23/16.
//
//

import Foundation

public protocol KeyStoreConvertible {
    var key: String { get }
}

public enum KeyStore: String, KeyStoreConvertible {
    case uuid
    case restServer
    case performedBiometricsSetup
    case hasSeenFeatureTour
    case logOutErrorMessage
    
    public var key: String { return rawValue }
}

public extension UserDefaults {
    
    final func value<T>(key: KeyStoreConvertible) -> T? {
        return value(forKey: key.key) as? T
    }
    
    final func bool(key: KeyStoreConvertible) -> Bool {
        return bool(forKey: key.key)
    }
    
    final func object(key: KeyStoreConvertible) -> Any? {
        return object(forKey: key.key)
    }
    
    final func set(value: Any?, key: KeyStoreConvertible) {
        set(value, forKey: key.key)
    }
    
    final func removeValue(key: KeyStoreConvertible) {
        removeObject(forKey: key.key)
    }
}
