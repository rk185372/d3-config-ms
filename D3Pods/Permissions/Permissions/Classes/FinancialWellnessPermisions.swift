//
//  FinancialWellnessPermisions.swift
//  Permissions
//
//  Created by Pablo Pellegrino on 03/11/2021.
//

import Foundation
import CompanyAttributes

public protocol FinancialWellnessPermisions {
    func isAccessible(_ feature: Feature) -> Bool
}

public struct FinancialWellnessPermisionsItem: FinancialWellnessPermisions {
    public let isEnabled: Bool
    public let isAdapterEnabled: Bool
    public let isMoneyMapEnabled: Bool
    public let isPulseEnabled: Bool
    
    public init(attributes: CompanyAttributes?) {
        isEnabled = attributes?.boolValue(forKey: "financial.wellness.enabled") ?? false
        isAdapterEnabled = attributes?.value(forKey: "financial.wellness.adapter.selected") == "MX"
        isMoneyMapEnabled = attributes?.boolValue(forKey: "financial.wellness.mx.client.moneyMap.enabled") ?? false
        isPulseEnabled = attributes?.boolValue(forKey: "financial.wellness.mx.client.pulse.enabled") ?? false
    }
    
    public func isAccessible(_ feature: Feature) -> Bool {
        guard isEnabled, isAdapterEnabled else {
            return false
        }
        switch feature {
        case .moneyMap:
            return isMoneyMapEnabled
        case .pulse:
            return isPulseEnabled
        default:
            return true
        }
    }
}
