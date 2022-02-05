//
//  OfflineAccount.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/29/19.
//

import Foundation

public final class OfflineAccount: Codable {
    public var name: String
    public var nickname: String?
    public var balance: Decimal
    public var source: String
    public var status: String
    public var associated: Bool
    public var product: RawAccountProduct

    public init(name: String,
                nickname: String? = nil,
                balance: Decimal,
                source: String,
                status: String,
                associated: Bool = true,
                product: RawAccountProduct) {
        self.name = name
        self.nickname = nickname
        self.balance = balance
        self.source = source
        self.status = status
        self.associated = associated
        self.product = product
    }
}

extension OfflineAccount {
    public func asData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
