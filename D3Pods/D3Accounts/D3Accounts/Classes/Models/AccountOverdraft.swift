//
//  AccountOverdraft.swift
//  Accounts
//
//  Created by Branden Smith on 3/15/18.
//

import Foundation

public struct AccountOverdraft: Codable, Equatable {
    let ach: Bool
    let checking: Bool

    public var isEnrolledInOverdraftProtection: Bool {
        return ach || checking
    }
}
