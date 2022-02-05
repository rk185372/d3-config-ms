//
//  AccountListItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/12/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Utilities

public struct AccountListItem: Codable, Equatable, DisplayNameable {
    
    public enum AccountType: String, Codable {
        case asset = "ASSET"
        case liability = "LIABILITY"
    }

    public enum AccountSource {
        public static let `internal` = "INTERNAL"
    }

    public enum AccountGroup {
        public static let assets = "assets"
        public static let liabilities = "liabilities"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case balance
        case balanceType
        case name
        case nickname
        case accountNumber
        case type
        case currencyCode
        case accountProduct
        case status
        case hidden
        case lastSyncTime
        case source
        case group
    }
    
    public let id: Int
    public let balance: Double
    public let balanceType: BalanceType
    public let name: String
    public let nickname: String?
    public let accountNumber: String?
    public let type: AccountType
    public let currencyCode: String
    public let accountProduct: String
    public let status: String
    public let hidden: Bool
    public let lastSyncTime: String?
    public let source: String
    public let group: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        balance = try container.decode(Double.self, forKey: .balance)
        balanceType = try container.decode(BalanceType.self, forKey: .balanceType)
        name = try container.decode(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
        type = try container.decode(AccountType.self, forKey: .type)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "USD"
        accountProduct = try container.decode(String.self, forKey: .accountProduct)
        status = try container.decode(String.self, forKey: .status)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        lastSyncTime = try container.decodeIfPresent(String.self, forKey: .lastSyncTime)
        source = try container.decode(String.self, forKey: .source)
        group = try container.decode(String.self, forKey: .group)
    }
}
