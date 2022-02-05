//
//  PermissionsManager.swift
//  Permissions
//
//  Created by Andrew Watt on 10/8/18.
//

import Foundation

public final class PermissionsManager {
    public var rdcAllowed = false
    public var locationsAllowed = false
    public var cardControlsAllowed = false
    public var financialWellnessPermissions: FinancialWellnessPermisions?
    public var roles: Set<UserRole> = []
    public let rules: [Feature: PermissionsRule]

    private let fwFeatures = Set<Feature>([.moneyMap, .pulse])
    
    public init(rules: [Feature: PermissionsRule]) {
        self.rules = rules
    }
    
    public func isAccessible(feature: Feature) -> Bool {
        if feature == .mrdc {
            return rdcAllowed
        }

        if feature == .locations {
            return locationsAllowed
        }
        
        if feature == .cardControls {
            return cardControlsAllowed
        }
        
        if fwFeatures.contains(feature),
           !(financialWellnessPermissions?.isAccessible(feature) ?? true) {
            return false
        }
        
        guard let rule = rules[feature] else {
            return true
        }
        
        if rule.subfeatures.isEmpty {
            return rule.roles.subtracting(roles).isEmpty
        } else {
            return rule.subfeatures.contains(where: isAccessible(feature:))
        }
    }
    
    public func hasRole(role: String, access: UserRole.Access = .read) -> Bool {
        return roles.contains(UserRole(name: role, access: access))
    }
}
