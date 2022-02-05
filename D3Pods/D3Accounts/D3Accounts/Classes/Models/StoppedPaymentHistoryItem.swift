//
//  StoppedPaymentHistoryItem.swift
//  Accounts
//
//  Created by Branden Smith on 4/18/18.
//

import Foundation

public enum StoppedPaymentType {
    case single
    case range
}

public struct StoppedPaymentHistoryItem: Codable, Equatable {
    public let confirmationNumber: String
    public let amount: Double?
    public let amountFrom: Double?
    public let amountTo: Double?
    public let checkNumber: String?
    public let checkNumberFrom: String?
    public let checkNumberTo: String?
    public let memo: String
    public let payee: String
    public let expirationDate: String
    public let status: String

    // We get the StoppedPaymentHistoryItem objects back in a single array
    // with two different object types. Becasue of this, we have the notion
    // of type here where the amount and check number signify that the
    // item is a single stopped payment and if these are not there
    // we assume that checkNumberTo and checkNumberFrom are present. This
    // would signify that the item is a range of payments. 
    public var type: StoppedPaymentType {
        if amount != nil && checkNumber != nil {
            return .single
        }

        return .range
    }
}
