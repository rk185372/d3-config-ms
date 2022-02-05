//
//  DispatchQueue+D3Queues.swift
//  D3 Banking
//
//  Created by Chris Carranza on 12/7/16.
//
//

import Foundation

public extension DispatchQueue {
    static let background: DispatchQueue =
        DispatchQueue(label: "com.d3banking.mobileapp.background", qos: DispatchQoS.background)
    static let utility: DispatchQueue =
        DispatchQueue(label: "com.d3banking.mobileapp.utility", qos: DispatchQoS.utility)
    static let userInitiated: DispatchQueue =
        DispatchQueue(label: "com.d3banking.mobileapp.userinitiated", qos: DispatchQoS.userInitiated)
    static let rdc: DispatchQueue =
        DispatchQueue(label: "com.d3banking.mrdc.standardcapture", qos: DispatchQoS.userInteractive)
    
    final func delay(_ delay: TimeInterval, closure:@escaping () -> Void) {
        asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
