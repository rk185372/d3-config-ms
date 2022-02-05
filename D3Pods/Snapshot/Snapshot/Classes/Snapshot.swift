//
//  Snapshot.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/12/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import D3Accounts
import Foundation
import Utilities

public struct Snapshot: Decodable {
    public struct AccountBalance: Decodable, Equatable {
        public let amount: Double
        public let type: BalanceType
        public let asOfDate: Date?

        public func formatted(currencyCode: String) -> String? {
            return NumberFormatter.currencyFormatter(currencyCode: currencyCode).string(from: amount)
        }
    }

    public struct Account: Decodable, Equatable {
        public let id: Int
        public let name: String
        public let balance: AccountBalance?
        public let balance2: AccountBalance?
        public let balance3: AccountBalance?
        public let group: String
        public let number: String
        public let transactions: [Transaction]?
        private let links: Links?

        private let _currencyCode: String?
        public var currencyCode: String {
            return _currencyCode ?? "USD"
        }

        public var accountTransactionsLink: String? {
            var path = links?.transactions?.href
            if path?.first == "/" {
                path?.removeFirst()
            }
            return path
        }

        private struct Links: Decodable, Equatable {
            let transactions: TransactionLink?
        }

        private struct TransactionLink: Decodable, Equatable {
            let href: String
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case balance
            case balance2
            case balance3
            case group
            case currencyCode
            case number
            case transactions
            case links
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            balance = try? container.decode(AccountBalance.self, forKey: .balance)
            balance2 = try? container.decode(AccountBalance.self, forKey: .balance2)
            balance3 = try? container.decode(AccountBalance.self, forKey: .balance3)
            group = try container.decode(String.self, forKey: .group)
            _currencyCode = try? container.decode(String.self, forKey: .currencyCode)
            number = try container.decode(String.self, forKey: .number)
            transactions = try? container.decode([Transaction].self, forKey: .transactions)
            links = try? container.decode(Links.self, forKey: .links)
        }
    }

    public struct Transaction: Decodable, Equatable {
        private let _amount: Double
        public var amount: Double {
            return type == "CREDIT" ? _amount : (_amount * -1)
        }

        public let pending: Bool
        public let postDate: Date?
        public let description: String
        public let type: String
        public let category: String

        enum CodingKeys: String, CodingKey {
            case amount
            case pending
            case postDate
            case description
            case type
            case category
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _amount = try container.decode(Double.self, forKey: .amount)
            pending = try container.decode(Bool.self, forKey: .pending)
            postDate = try? container.decode(Date.self, forKey: .postDate)
            description = try container.decode(String.self, forKey: .description)
            type = try container.decode(String.self, forKey: .type)
            category = try container.decode(String.self, forKey: .category)
        }
    }

    public struct WrappedTransaction: Decodable, Equatable {
        public let accountName: String
        public let currencyCode: String
        public let transaction: Transaction
    }

    public let syncStatus: SnapshotSyncStatus
    
    private let _accounts: [Account]?
    public var accounts: [Account] {
        return _accounts ?? []
    }

    enum CodingKeys: CodingKey {
        case syncStatus
        case accounts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        syncStatus = try container.decode(SnapshotSyncStatus.self, forKey: .syncStatus)
        _accounts = try? container.decode([Account].self, forKey: .accounts)
    }

    public var isSingleAccount: Bool {
        return accounts.count == 1
    }
}

public struct SnapshotWidget: Decodable {
    public let transactions: [Snapshot.WrappedTransaction]?
    
    public let syncStatus: SnapshotSyncStatus
    private let _accounts: [Snapshot.Account]?
    public var accounts: [Snapshot.Account] {
        return _accounts ?? []
    }
    
    enum CodingKeys: CodingKey {
        case syncStatus
        case accounts
        case transactions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        syncStatus = try container.decode(SnapshotSyncStatus.self, forKey: .syncStatus)
        
        transactions = try? container.decode([Snapshot.WrappedTransaction].self, forKey: .transactions)
        
        _accounts = try? container.decode([Snapshot.Account].self, forKey: .accounts)
    }
}
