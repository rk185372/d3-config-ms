//
//  EDocsSelectionResult.swift
//  EDocs
//
//  Created by Branden Smith on 1/7/20.
//

import Foundation

enum EDocsSelectionResult {
    case estatement(
        accounts: [EDocsPromptAccount],
        requestConfig: EDocsRequestConfiguration,
        confirmationConfig: EDocsConfirmationConfiguration
    )
    case notices(accounts: [EDocsPromptAccount], confirmationConfig: EDocsConfirmationConfiguration)
    case taxDocs(confirmationConfig: EDocsConfirmationConfiguration)
}
