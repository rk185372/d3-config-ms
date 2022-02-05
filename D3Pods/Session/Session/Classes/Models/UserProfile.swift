//
//  UserProfile.swift
//  Session
//
//  Created by Andrew Watt on 10/9/18.
//

import Foundation
import Permissions

public struct Destination: Codable, Equatable {
    
    public init(id: Int?,
                type: String,
                label: String,
                value: String,
                primary: Bool,
                outOfBand: Bool,
                readOnly: Bool,
                verified: Bool,
                alternate: Bool?,
                subType: String?,
                sms: Bool?) {
        
        self.id = id
        self.type = type
        self.label = label
        self.value = value
        self.primary = primary
        self.outOfBand = outOfBand
        self.readOnly = readOnly
        self.verified = verified
        self.alternate = alternate
        self.subType = subType
        self.sms = sms
    }
    
    public var id: Int?
    public var type: String
    public var label: String
    public var value: String
    public var primary: Bool
    public var outOfBand: Bool
    public var readOnly: Bool
    public var verified: Bool
    public var alternate: Bool?
    public var subType: String?
    public var sms: Bool?
}

public struct UserProfile: Codable, Equatable {
    public struct Address: Codable, Equatable {
        public var line1: String?
        public var line2: String?
        public var line3: String?
        public var line4: String?
        public var city: String?
        public var state: String?
        public var countryCode: String?
        public var postalCode: String?
        public var latitude: Double?
        public var longitude: Double?
    }
    
    public struct DestinationInterface: Codable, Equatable {
        public var interfaceName: String
        public var internalName: String
        public var repeatable: Bool
        public var mobileType: Bool?
        public var order: Int?
        public var destinationType: String
    }
    
    public struct Permission: Codable, Equatable {
        public enum Access: String, Codable {
            case create = "CREATE"
            case delete = "DELETE"
            case read = "READ"
            case update = "UPDATE"
        }
        
        public var access: [Access]
    }
    
    public var attributes: [String: String]?
    public var authorizedApprovalTypes: [String]?
    public var businessName: String?
    public var dateOfBirth: String?
    public var emailAddresses: [Destination]
    public var enrolled: Bool
    public var firstName: String?
    public var inbox: Destination
    public var lastName: String?
    public var loginId: String
    public var mailingAddress: Address?
    public var middleName: String?
    public var phoneNumbers: [Destination]
    public var physicalAddress: Address?
    public var previousLogin: String?
    public var profileType: String
    public var push: Destination?
    public var servicePermissions: [String: Permission]
    public var taxIdExists: Bool?
    public var type: String
    public var validEmailTypes: [DestinationInterface]
    public var validPhoneTypes: [DestinationInterface]
    public var validProfileModes: [String]
    
    var roles: Set<UserRole> {
        let roles = servicePermissions.flatMap { (name, permission) -> [UserRole] in
            return permission.access.map { access in
                return UserRole(name: name, access: UserRole.Access(access))
            }
        }
        return Set(roles)
    }
}

extension UserRole.Access {
    init(_ access: UserProfile.Permission.Access) {
        switch access {
        case .create:
            self = .create
        case .delete:
            self = .delete
        case .read:
            self = .read
        case .update:
            self = .update
        }
    }
}
