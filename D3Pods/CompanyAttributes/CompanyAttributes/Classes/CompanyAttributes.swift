//
//  CompanyAttributes.swift
//  AppInitialization
//
//  Created by Branden Smith on 6/19/18.
//

import Foundation

public struct CompanyAttributes {
    private let dictionary: [String: Any]
    
    public init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public func intValue(forKey key: String) -> Int {
        return value(forKey: key)!
    }

    public func stringValue(forKey key: String) -> String {
        return value(forKey: key)!
    }

    public func boolValue(forKey key: String) -> Bool {
        return value(forKey: key) ?? false
    }
    
    public func value<T>(forKey key: String) -> T? {
        return dictionary[key] as? T
    }
    
    public func exists(key: String) -> Bool {
        return dictionary[key] != nil
    }
}
