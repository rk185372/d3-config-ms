//
//  Transaction.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/12/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Utilities

public enum TransactionType: String, Codable {
    case debit = "DEBIT"
    case credit = "CREDIT"
}

public enum TransactionStatus: String, Codable {
    case posted = "POSTED"
    case pending = "PENDING"
}

public struct Transaction: Decodable {
    public let id: Int
    public let name: String?
    public let amount: Double
    public let balance: Double?
    public let date: Date
    public let type: TransactionType
    public let status: TransactionStatus
    public let currencyCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case balance
        case date
        case type
        case status
        case currencyCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        amount = try container.decode(Double.self, forKey: .amount)
        balance = try container.decodeIfPresent(Double.self, forKey: .balance)
        date = try container.decode(Date.self, forKey: .date, dateFormatter: DateFormatter.shortStyleDashes)
        type = try container.decode(TransactionType.self, forKey: .type)
        status = try container.decode(TransactionStatus.self, forKey: .status)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "USD"
    }
}

extension Transaction: Equatable {
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        guard lhs.amount == rhs.amount else { return false }
        guard lhs.balance == rhs.balance else { return false }
        guard lhs.date == rhs.date else { return false }
        guard lhs.type == rhs.type else { return false }
        guard lhs.status == rhs.status else { return false }
        
        return true
    }
}
