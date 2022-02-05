//
//  EDocsRequest.swift
//  EDocs
//
//  Created by Branden Smith on 12/8/17.
//

import Foundation

public struct EDocsRequest {
    public struct Account {
        public let userAccountId: Int
        
        func dictionary() -> [String: Any] {
            return [
                "userAccountId": userAccountId,
                "type": "ELECTRONIC"
            ]
        }
    }
    
    public let accounts: [Account]
    private let promptConfig: EDocsRequestConfiguration

    init(accounts: [Account], configuration: EDocsRequestConfiguration) {
        self.accounts = accounts
        self.promptConfig = configuration
    }
    
    func dictionary() -> [String: Any] {
        return [
            "accounts": accounts.map { $0.dictionary() },
            "paperlessPrompt": promptConfig.paperlessPrompt,
            "estatementPrompt": promptConfig.estatementPrompt
        ]
    }
}

extension EDocsRequest.Account {
    init(promptAccount: EDocsPromptAccount) {
        self.init(userAccountId: promptAccount.userAccountId)
    }
}

extension EDocsRequest {
    init(promptAccounts: [EDocsPromptAccount], configuration: EDocsRequestConfiguration) {
        self.init(accounts: promptAccounts.map(Account.init(promptAccount:)), configuration: configuration)
    }
}
