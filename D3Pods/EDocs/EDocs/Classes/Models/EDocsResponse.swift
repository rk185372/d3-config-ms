//
//  EDocsResponse.swift
//  EDocs
//
//  Created by Chris Carranza on 1/18/18.
//

import Foundation

public struct EDocsResponse: Decodable, Equatable {
    public struct Account: Decodable, Equatable {
        public let userAccountId: Int
        public let success: Bool
    }
    
    public let accounts: [Account]
}

public enum EDocsNetworkResult {
    case success(response: EDocsResponse, confirmationConfig: EDocsConfirmationConfiguration)
    case failure(confirmationConfig: EDocsConfirmationConfiguration)
}
