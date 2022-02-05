//
//  EDocsResultProvider.swift
//  EDocs
//
//  Created by Branden Smith on 1/7/20.
//

import Foundation

protocol EDocsResultProvider {
    func getEDocsResult(given accounts: [EDocsPromptAccount]) -> EDocsSelectionResult
}

struct EstatementTypeResultProvider: EDocsResultProvider {
    let confirmationConfig: EDocsConfirmationConfiguration

    init(confirmationConfig: EDocsConfirmationConfiguration) {
        self.confirmationConfig = confirmationConfig
    }

    func getEDocsResult(given accounts: [EDocsPromptAccount]) -> EDocsSelectionResult {
        return .estatement(
            accounts: accounts,
            requestConfig: EDocsRequestConfiguration(paperlessPrompt: false, estatementPrompt: true),
            confirmationConfig: confirmationConfig
        )
    }
}

struct GoPaperlessTypeResultProvider: EDocsResultProvider {
    let confirmationConfig: EDocsConfirmationConfiguration

    init(confirmationConfig: EDocsConfirmationConfiguration) {
        self.confirmationConfig = confirmationConfig
    }

    func getEDocsResult(given accounts: [EDocsPromptAccount]) -> EDocsSelectionResult {
        return .estatement(
            accounts: accounts,
            requestConfig: EDocsRequestConfiguration(paperlessPrompt: true, estatementPrompt: false),
            confirmationConfig: confirmationConfig
        )
    }
}

struct NoticesTypeResultProvider: EDocsResultProvider {
    let confirmationConfig: EDocsConfirmationConfiguration

    init(confirmationConfig: EDocsConfirmationConfiguration) {
        self.confirmationConfig = confirmationConfig
    }

    func getEDocsResult(given accounts: [EDocsPromptAccount]) -> EDocsSelectionResult {
        return .notices(accounts: accounts, confirmationConfig: confirmationConfig)
    }
}

struct TaxDocsTypeResultProvider: EDocsResultProvider {
    let confirmationConfig: EDocsConfirmationConfiguration

    init(confirmationConfig: EDocsConfirmationConfiguration) {
        self.confirmationConfig = confirmationConfig
    }

    func getEDocsResult(given accounts: [EDocsPromptAccount]) -> EDocsSelectionResult {
        return .taxDocs(confirmationConfig: confirmationConfig)
    }
}
