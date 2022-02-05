//
//  Card.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import Foundation

public struct Card: Codable, Equatable {
    public let id: String
    public let maskedCardNumber: String
    public let signerName: String
    public var activated: Bool
}
