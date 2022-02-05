//
//  RDCRequest.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/28/18.
//

import Foundation
import Wrap

public struct RDCRequest: Codable, Equatable {
    var deviceUuid: String
    var account: DepositAccount
    var amount: Decimal
    var frontImage: String?
    var backImage: String?
    var finalizeOnly: Bool = false
    var sessionId: String?
    var accountKeys: [String]?
    
    var localDateTime: String
}

public struct RDCResponse: Codable, Equatable {
    let success: Bool?
    let confirmation: Int?
    let errorCode: Int?
    let confirmationRequired: Bool?
    let retakeImageRequired: Bool?
    let errorDescription: String?
    let message: String?
    let errorMessages: [String]?
}

extension RDCRequest {
    func asData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
