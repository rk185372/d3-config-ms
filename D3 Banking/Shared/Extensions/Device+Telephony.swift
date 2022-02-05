//
//  Device+Telephony.swift
//  D3 Banking
//
//  Created by Andrew Watt on 7/6/18.
//

import Foundation
import CoreTelephony
import Utilities

public extension Device {
    static func currentCarrier() -> String {
        let info = CTTelephonyNetworkInfo()
        guard let carrier = info.subscriberCellularProvider else {
            return ""
        }
        
        var carrierString = ""
        
        if let carrierName = carrier.carrierName {
            carrierString += "\(carrierName) "
        }

        if
            let mobileCountryCode = carrier.mobileCountryCode,
            let mobileNetworkCode = carrier.mobileNetworkCode,
            !mobileNetworkCode.isEmpty,
            !mobileCountryCode.isEmpty {
            carrierString += "(\(mobileCountryCode) \(mobileNetworkCode))"
        }
        
        return carrierString.trimmingCharacters(in: .whitespaces)
    }
}
