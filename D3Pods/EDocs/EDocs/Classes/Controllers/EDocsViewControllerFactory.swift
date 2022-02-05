//
//  EDocsViewControllerFactory.swift
//  EDocs
//
//  Created by Andrew Watt on 8/24/18.
//

import Foundation
import CompanyAttributes
import ComponentKit
import Localization

public final class EDocsViewControllerFactory {
    private let config: ComponentConfig
    private let edocsService: EDocsService
    private let companyAttributes: CompanyAttributesHolder
    
    public init(config: ComponentConfig,
                edocsService: EDocsService,
                companyAttributes: CompanyAttributesHolder) {
        self.config = config
        self.edocsService = edocsService
        self.companyAttributes = companyAttributes
    }
    
    func createPrompt(paperlessConfig: EDocsPromptConfiguration,
                      edocsOptions: EDocOptions) -> UIViewController {
        let viewController = EDocsPromptViewController(
            config: config,
            promptConfiguration: paperlessConfig,
            edocsOptions: edocsOptions,
            edocsService: edocsService
        )

        return viewController
    }
    
    func createAccountSelection(accounts: [EDocsPromptAccount],
                                edocsConfiguration: EDocsConfiguration,
                                edocsPreferencesConfig: EDocsPreferencesConfig? = nil,
                                resultProvider: EDocsResultProvider,
                                l10nProvider: L10nProvider) -> UIViewController {
        let viewModel = AccountSelectionViewModel(accounts: accounts, l10nProvider: l10nProvider)
        let viewController = EDocsAccountSelectionViewController(
            config: config,
            accountSelectionConfig: edocsConfiguration.accountSelectionConfiguration,
            edocsPreferencesConfig: edocsPreferencesConfig,
            resultProvider: resultProvider,
            viewModel: viewModel,
            service: edocsService,
            disclosureConfig: edocsConfiguration.disclosureConfiguration
        )

        return viewController
    }

    func createLegacyAccountSelection(accounts: [EDocsPromptAccount],
                                      edocsConfiguration: EDocsConfiguration,
                                      resultProvider: EDocsResultProvider,
                                      l10nProvider: L10nProvider) -> UIViewController {
        let viewModel = AccountSelectionViewModel(accounts: accounts, l10nProvider: l10nProvider)
        let viewController = EDocsLegacyAccountSelectionViewController(
            config: config,
            accountSelectionConfig: edocsConfiguration.accountSelectionConfiguration,
            resultProvider: resultProvider,
            viewModel: viewModel,
            service: edocsService,
            disclosureConfig: edocsConfiguration.disclosureConfiguration
        )

        return viewController
    }

    func createTaxDocsSelection(edocsConfiguration: EDocsConfiguration,
                                edocsPreferencesConfig: EDocsPreferencesConfig,
                                resultProvider: EDocsResultProvider,
                                l10nProvider: L10nProvider) -> UIViewController {
        return TaxDocsEnrollmentViewController(
            accountSelectionConfig: edocsConfiguration.accountSelectionConfiguration,
            edocsPreferencesConfig: edocsPreferencesConfig,
            resultProvider: resultProvider,
            service: edocsService,
            disclosureConfig: edocsConfiguration.disclosureConfiguration,
            companyAttributes: companyAttributes,
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider
        )
    }
    
    func createConfirmation() -> UIViewController {
        let viewController = EDocsConfirmationViewController(config: config, service: edocsService)

        return viewController
    }
}
