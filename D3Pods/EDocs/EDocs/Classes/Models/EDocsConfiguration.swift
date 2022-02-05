//
//  EDocsConfiguration.swift
//  EDocs
//
//  Created by Branden Smith on 12/13/18.
//

import ComponentKit
import Foundation
import LegalContent
import UIKit

public struct EDocsConfiguration {
    let accountSelectionConfiguration: EDocsAccountSelectionConfiguration
    let confirmationConfiguration: EDocsConfirmationConfiguration
    let disclosureConfiguration: EDocsDisclosureConfig
}

public struct EDocsPromptConfiguration {
    let infoLabelText: String
    let whyLabelText: String
    let submitButtonText: String
    let declineButtonText: String
    let learnMoreButtonText: String
    let centerIcon: UIImage?
    let logoImage: UIImage?
}

struct EDocsAccountSelectionConfiguration {
    let headerText: String
    let infoLabelText: String
    let submitButtonText: String
    let declineButtonText: String
    let selectAllCheckboxTitle: String
    let selectsAllByDefault: Bool
    let viewDisclosureButtonText: String
    let logoImage: UIImage?
    let paperlessRequestConfiguration: EDocsRequestConfiguration
}

public struct EDocsConfirmationConfiguration: Equatable {
    let sortKey: EDocsSortKey
    let sectionTitle: String
    let successTitle: String
    let failureTitle: String
}

public struct EDocsRequestConfiguration {
    let paperlessPrompt: Bool
    let estatementPrompt: Bool
}

public struct EDocsPreferencesConfig {
    let electronicDocumentType: EDocsDocumentType

    init(documentType: EDocsDocumentType) {
        self.electronicDocumentType = documentType
    }
}

struct EDocsDisclosureConfig {
    let legalService: LegalContentService
    let legalServiceType: LegalServiceType
    let disclosureViewControllerFactory: DisclosureViewControllerFactory
    let errorTitle: String
    let errorMessage: String
}
