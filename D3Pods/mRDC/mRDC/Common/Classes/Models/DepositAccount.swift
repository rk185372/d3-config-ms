//
//  DepositAccount.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/13/18.
//

import Foundation
import Utilities

let rdcAmountKey = "d3MoneyMovement.rdc.amount"
let rdcLimitKey = "d3MoneyMovement.rdc.limit"
let rdcDurationKey = "d3MoneyMovement.rdc.duration"
let rdcRemainingAmountKey = "d3MoneyMovement.rdc.remaining.deposit.amount"
let rdcRemainingDepositCountKey = "d3MoneyMovement.rdc.remaining.deposit.count"
let rdcTier2LimitKey = "d3MoneyMovement.rdc.tier_2.limit"
let rdcTier2RemainingDepositCountKey = "d3MoneyMovement.rdc.tier_2.remaining.deposit.count"
let rdcTier2DurationKey = "d3MoneyMovement.rdc.tier_2.duration"
let rdcTier2RemainingAmountKey = "d3MoneyMovement.rdc.tier_2.remaining.deposit.amount"
let rdcTier2AmountKey = "d3MoneyMovement.rdc.tier_2.amount"

public enum RDCDuration {
    case daily
    case weekly
    case monthly
}

public struct DepositAccount: Codable, Equatable {
    public let id: Int
    public let name: String
    public let nickname: String?
    public let balance: Double
    public let currencyCode: String
    public let number: String?
    public let attributes: [DepositAccountAttributes]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nickname
        case balance
        case currencyCode
        case number
        case attributes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        balance = try container.decode(Double.self, forKey: .balance)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "USD"
        number = try container.decodeIfPresent(String.self, forKey: .number)
        attributes = try container.decode([DepositAccountAttributes].self, forKey: .attributes)
    }
}

extension DepositAccount: DisplayNameable {}

public struct DepositAccountAttributes: Codable, Equatable {
    let name: String
    let value: String
    let type: String
    let displayOrder: Int
}

extension DepositAccount {
    
    func hasLimits() -> Bool {
        return limit() != nil || amount() != nil
    }
    
    //MARK: - Fetching Amount
    private func amount(for key: String) -> String? {
        guard let amountAttr = attributes.first(where: { $0.name == key }),
            let amount = Double(amountAttr.value),
            amount > 0 else {
                return nil
        }
        return NumberFormatter.currencyFormatter(currencyCode: currencyCode).string(from: amount)
    }
    
    func amount() -> String? { return amount(for: rdcAmountKey) }
    
    func tier2Amount() -> String? { return amount(for: rdcTier2AmountKey) }
    
    //MARK: - Fetching Limit
    private func limit(for key: String) -> String? {
            guard let limitAttr = attributes.first(where: { $0.name == key }),
                let limitInt = Int(limitAttr.value),
                limitInt >= 0 else {
                    return "0"
            }
            return limitAttr.value
        }

    func limit() -> String? { return limit(for: rdcLimitKey) }

    func tier2Limit() -> String? { return limit(for: rdcTier2LimitKey) }
    
    //MARK: - Fetching Count
    private func depositCount(for key: String) -> String? {
        guard let depositCountAttr = attributes.first(where: { $0.name == key }),
            let limitInt = Int(depositCountAttr.value),
            limitInt >= 0 else {
                return "0"
        }
        return depositCountAttr.value
    }
    
    func depositCount() -> String? { return depositCount(for: rdcRemainingDepositCountKey) }
    
    func tier2DepositCount() -> String? { return depositCount(for: rdcTier2RemainingDepositCountKey) }
    
    //MARK: - Fetching Duration
    private func duration(for key: String) -> RDCDuration? {
            guard let durationAttr = attributes.first(where: { $0.name == key }) else {
                    return nil
            }
            
            switch durationAttr.value {
            case "DAILY":
                return .daily
            case "WEEKLY":
                return .weekly
            default:
                return .monthly
            }
        }

    func duration() -> RDCDuration? { return duration(for: rdcDurationKey) }

    func tier2Duration() -> RDCDuration? { return duration(for: rdcTier2DurationKey) }

    //MARK: - Fetching Remaining Amount

    func remainingAmount() -> String? { return amount(for: rdcRemainingAmountKey) }

    func tier2RemainingAmount() -> String? { return amount(for: rdcTier2RemainingAmountKey) }
}
