//
//  DisplayNameable.swift
//  Accounts
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation

public protocol DisplayNameable {
    var name: String { get }
    var nickname: String? { get }
    var displayableName: String { get }
}

extension DisplayNameable {
    public var displayableName: String {
        if let nickname = self.nickname, !nickname.isEmpty {
            return nickname
        }

        return name
    }
}
