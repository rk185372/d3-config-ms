//
//  Bundle+Generics.swift
//  Pods
//
//  Created by Chris Carranza on 3/29/17.
//
//

import Foundation

extension Bundle {
    public final func valueForKey<T>(_ key: String) -> T? {
        return object(forInfoDictionaryKey: key) as? T
    }
    
    public final func boolValueForKey(_ key: String) -> Bool? {
        return valueForKey(key)
    }
    
    public final func stringValueForKey(_ key: String) -> String? {
        return valueForKey(key)
    }
    
    public final func intValueForKey(_ key: String) -> Int? {
        return valueForKey(key)
    }
}
