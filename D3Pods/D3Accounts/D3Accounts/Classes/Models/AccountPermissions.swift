//
//  AccountPermissions.swift
//  Accounts
//
//  Created by Branden Smith on 3/15/18.
//

import Foundation

public struct AccountPermissions: Codable, Equatable {
    public let eligibleForCards: Bool
    public let allowCheckOrders: Bool
    public let overdraftProtection: Bool
    public let stopPayment: Bool
    public let allowBrokerageAccess: Bool

    enum CodingKeys: String, CodingKey {
        case eligibleForCards
        case allowCheckOrders
        case overdraftProtection
        case stopPayment
        case allowBrokerageAccess
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        eligibleForCards = try container.decodeIfPresent(Bool.self, forKey: .eligibleForCards) ?? false
        allowCheckOrders = try container.decodeIfPresent(Bool.self, forKey: .allowCheckOrders) ?? false
        overdraftProtection = try container.decodeIfPresent(Bool.self, forKey: .overdraftProtection) ?? false
        stopPayment = try container.decodeIfPresent(Bool.self, forKey: .stopPayment) ?? false
        allowBrokerageAccess = try container.decodeIfPresent(Bool.self, forKey: .allowBrokerageAccess) ?? false
    }
}
