//
//  DepositTransaction.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/2/18.
//

import Foundation
import Utilities

public struct DepositTransaction: Codable, Equatable {
    let transactionId: String
    let formattedTransactionDateTime: Date
    let postedAmount: Double?
    let adjustedAmount: Double?
    let currentAmount: Double
    let status: String
    let confirmationNumber: String?
}

extension DepositTransaction {
    func dateAndTimeString() -> String? {
        return DateFormatter.longStyleSlashes.string(from: formattedTransactionDateTime)
    }

    func dateString() -> String? {
        return DateFormatter.longStyleExcludingTime.string(from: formattedTransactionDateTime)
    }
}

struct DepositTransactionGroup: Codable, Equatable {
    let title: String
    let transactions: [DepositTransaction]
}
