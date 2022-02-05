//
//  BalanceType.swift
//  Utilities
//
//  Created by Andrew Watt on 8/30/18.
//

import Foundation

public enum BalanceType: String, Codable, Equatable {
    case available = "AVAILABLE"
    case ledger = "LEDGER"
    case additional = "ADDITIONAL"
    
    public var l10nKey: String {
        switch self {
        case .available:
            return "launchPage.snapshot.detail.available"
        case .ledger:
            return "launchPage.snapshot.detail.ledger"
        case .additional:
            return "launchPage.snapshot.detail.additional"
        }
    }
}
