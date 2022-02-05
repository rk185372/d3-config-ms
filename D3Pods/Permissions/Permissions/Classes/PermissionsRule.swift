//
//  PermissionsRule.swift
//  Permissions
//
//  Created by Andrew Watt on 10/19/18.
//

import Foundation

public struct PermissionsRule {
    public var roles: Set<UserRole>
    public var subfeatures: [Feature]
    
    public init(roles: Set<UserRole> = [], subfeatures: [Feature] = []) {
        self.roles = roles
        self.subfeatures = subfeatures
    }
}
