//
//  StopPaymentResponse.swift
//  Accounts
//
//  Created by Branden Smith on 4/16/18.
//

import Foundation

public struct StopPaymentResponse: Codable {
    public let confirmationNumber: String
    public let statusText: String
    public let statusCode: String
}
