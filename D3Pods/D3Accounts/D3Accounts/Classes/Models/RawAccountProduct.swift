//
//  RawAccountProduct.swift
//  Accounts
//
//  Created by Branden Smith on 1/25/19.
//

import Foundation

public struct RawAccountProduct: Codable, Equatable {
    public enum RawAccountingClass: String, Codable {
        case asset = "ASSET"
        case liability = "LIABILITY"
    }

    public let id: Int
    public let name: String
    public let accountingClass: RawAccountingClass
}
