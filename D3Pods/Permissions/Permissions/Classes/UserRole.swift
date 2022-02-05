//
//  UserRole.swift
//  Permissions
//
//  Created by Andrew Watt on 10/18/18.
//

import Foundation

public struct UserRole: Hashable {
    public enum Access: String {
        case create
        case delete
        case read
        case update        
    }

    public var name: String
    public var access: Access
    
    public var value: String {
        return "\(name).\(access.rawValue)"
    }
    
    public init(name: String, access: Access) {
        self.name = name
        self.access = access
    }
    
    public init?(value: String) {
        guard
            let range = value.range(of: ".", options: .backwards),
            let access = Access(rawValue: String(value[range.upperBound...])) else {
            return nil
        }
        self.name = String(value[..<range.lowerBound])
        self.access = access
    }
}

extension UserRole: CustomStringConvertible {
    public var description: String {
        return value
    }
}
