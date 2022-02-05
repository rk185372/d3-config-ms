//
//  EDocsPostAuthStepFactory.swift
//  EDocs
//
//  Created by Branden Smith on 12/11/19.
//

import ComponentKit
import Foundation
import Localization
import PostAuthFlowController

public final class EDocsPostAuthStepFactory {
    private let edocsViewControllerFactory: EDocsViewControllerFactory
    private let edocsConfigurationFactory: EDocsConfigurationFactory
    private let l10nProvider: L10nProvider

    public init(edocsViewControllerFactory: EDocsViewControllerFactory,
                edocsConfigurationFactory: EDocsConfigurationFactory,
                l10nProvider: L10nProvider) {
        self.edocsViewControllerFactory = edocsViewControllerFactory
        self.edocsConfigurationFactory = edocsConfigurationFactory
        self.l10nProvider = l10nProvider
    }

    public func create(paperlessPromptAccounts: [EDocsPromptAccount],
                       estatementPromptAccounts: [EDocsPromptAccount],
                       accountNoticePromptAccounts: [EDocsPromptAccount],
                       promptForElectronicTaxDocuments: Bool,
                       postAuthFlowController: PostAuthFlowController) -> PostAuthStep? {
        var stepables: [EDocsStepable] = []
        var options: EDocOptions = []

        if !paperlessPromptAccounts.isEmpty {
            options.insert(.goPaperless)

            let goPaperlessConfig = edocsConfigurationFactory.goPaperlessConfiguration()

            stepables.append(
                edocsViewControllerFactory.createLegacyAccountSelection(
                    accounts: paperlessPromptAccounts,
                    edocsConfiguration: goPaperlessConfig,
                    resultProvider: GoPaperlessTypeResultProvider(confirmationConfig: goPaperlessConfig.confirmationConfiguration),
                    l10nProvider: l10nProvider
                ) as! EDocsStepable
            )
        }

        if !estatementPromptAccounts.isEmpty {
            options.insert(.estatements)

            let estatementsConfig = edocsConfigurationFactory.estatementConfiguration()

            stepables.append(
                edocsViewControllerFactory.createLegacyAccountSelection(
                    accounts: estatementPromptAccounts,
                    edocsConfiguration: estatementsConfig,
                    resultProvider: EstatementTypeResultProvider(confirmationConfig: estatementsConfig.confirmationConfiguration),
                    l10nProvider: l10nProvider
                ) as! EDocsStepable
            )
        }

        if !accountNoticePromptAccounts.isEmpty {
            options.insert(.notices)

            let noticesConfig = edocsConfigurationFactory.noticesConfiguration()

            stepables.append(
                edocsViewControllerFactory.createAccountSelection(
                    accounts: accountNoticePromptAccounts,
                    edocsConfiguration: noticesConfig,
                    edocsPreferencesConfig: EDocsPreferencesConfig(documentType: .notice),
                    resultProvider: NoticesTypeResultProvider(
                        confirmationConfig: noticesConfig.confirmationConfiguration
                    ),
                    l10nProvider: l10nProvider
                ) as! EDocsStepable
            )
        }

        if promptForElectronicTaxDocuments {
            options.insert(.taxDocs)

            let taxDocsConfig = edocsConfigurationFactory.taxDocsConfiguration()

            stepables.append(
                edocsViewControllerFactory.createTaxDocsSelection(
                    edocsConfiguration: taxDocsConfig,
                    edocsPreferencesConfig: EDocsPreferencesConfig(documentType: .tax),
                    resultProvider: TaxDocsTypeResultProvider(confirmationConfig: taxDocsConfig.confirmationConfiguration),
                    l10nProvider: l10nProvider
                ) as! EDocsStepable
            )
        }

        // If the stepables is empty up to this point, there is no need to show the prompt, so we
        // skip out. Otherwise, we will put the prompt at the begining of the stables array so
        // that it is shown first then we create the post auth step.
        guard !stepables.isEmpty else { return nil }

        // If the stepables is non empty then there is at least one step that may require
        // a confirmation page. Because of this, we add the confirmation view controller to the
        // stepables here and leave it to the EDocsPostAuthStep to show or not show the view controller.
        stepables.append(
            edocsViewControllerFactory.createConfirmation() as! EDocsStepable
        )

        stepables.insert(
            edocsViewControllerFactory.createPrompt(
                paperlessConfig: edocsConfigurationFactory.edocsPromptConfiguration(),
                edocsOptions: options
            ) as! EDocsStepable,
            at: 0
        )

        return EDocsPostAuthStep(steps: stepables, postAuthFlowController: postAuthFlowController)
    }
}
