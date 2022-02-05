//
//  StoppedPayment.swift
//  Accounts
//
//  Created by Branden Smith on 4/9/18.
//

import Foundation

public final class StoppedPayment {
    public var amount: Double = 0.0
    public var checkNumber: String = ""
    public var payee: String = ""
    public let type: String = "single"

    public init() {}
}
