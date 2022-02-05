//
//  EDocsConfigurationFactory.swift
//  EDocs
//
//  Created by Branden Smith on 12/13/18.
//

import CompanyAttributes
import ComponentKit
import Foundation
import LegalContent
import Localization

public final class EDocsConfigurationFactory {
    private let legalService: LegalContentService
    private let disclosureViewControllerFactory: DisclosureViewControllerFactory
    private let l10nProvider: L10nProvider
    private let companyAttributes: CompanyAttributesHolder

    public init(legalService: LegalContentService,
                disclosureViewControllerFactory: DisclosureViewControllerFactory,
                l10nProvider: L10nProvider,
                companyAttributes: CompanyAttributesHolder) {
        self.legalService = legalService
        self.disclosureViewControllerFactory = disclosureViewControllerFactory
        self.l10nProvider = l10nProvider
        self.companyAttributes = companyAttributes
    }

    public func edocsPromptConfiguration() -> EDocsPromptConfiguration {
        return EDocsPromptConfiguration(
            infoLabelText: l10nProvider.localize("edocs-prompt.ability.title"),
            whyLabelText: l10nProvider.localize("edocs-prompt.why.text"),
            submitButtonText: l10nProvider.localize("edocs-prompt.btn.yes"),
            declineButtonText: l10nProvider.localize("edocs-prompt.btn.no"),
            learnMoreButtonText: l10nProvider.localize("edocs-prompt.learn-more.btn"),
            centerIcon: UIImage(named: "EDocs"),
            logoImage: UIImage(named: "FullLogo")
        )
    }

    public func edocsRequestConfiguration() -> EDocsRequestConfiguration {
        return EDocsRequestConfiguration(
              paperlessPrompt: true,
              estatementPrompt: false
          )
    }

    public func goPaperlessConfiguration() -> EDocsConfiguration {
        return EDocsConfiguration(
            accountSelectionConfiguration: EDocsAccountSelectionConfiguration(
                headerText: l10nProvider.localize("edocs-selection.estatements.title"),
                infoLabelText: l10nProvider.localize("edocs-selection.estatements.info.text"),
                submitButtonText: l10nProvider.localize("edocs-selection.estatements.btn.yes"),
                declineButtonText: l10nProvider.localize("edocs-selection.estatements.btn.no"),
                selectAllCheckboxTitle: l10nProvider.localize("edocs-selection.estatements.btn.select-all"),
                selectsAllByDefault: companyAttributes
                    .companyAttributes
                    .value?
                    .boolValue(forKey: "accounts.estatement.enrollAll.default") ?? false,
                viewDisclosureButtonText: l10nProvider.localize("edocs-selection.estatements.btn.view-disclosure"),
                logoImage: UIImage(named: "FullLogo"),
                paperlessRequestConfiguration: EDocsRequestConfiguration(
                    paperlessPrompt: true,
                    estatementPrompt: false
                )
            ),
            confirmationConfiguration: estatementTypeConfirmationConfig(sortKey: .goPaperless),
            disclosureConfiguration: EDocsDisclosureConfig(
                legalService: legalService,
                legalServiceType: .goPaperless,
                disclosureViewControllerFactory: disclosureViewControllerFactory,
                errorTitle: l10nProvider.localize("app.error.generic.title"),
                errorMessage: l10nProvider.localize("edocs-selection.estatements.disclosure.error")
            )
        )
    }

    public func estatementConfiguration() -> EDocsConfiguration {
        return EDocsConfiguration(
            accountSelectionConfiguration: EDocsAccountSelectionConfiguration(
                headerText: l10nProvider.localize("edocs-selection.estatements.title"),
                infoLabelText: l10nProvider.localize("edocs-selection.estatements.info.text"),
                submitButtonText: l10nProvider.localize("edocs-selection.estatements.btn.yes"),
                declineButtonText: l10nProvider.localize("edocs-selection.estatements.btn.no"),
                selectAllCheckboxTitle: l10nProvider.localize("edocs-selection.estatements.btn.select-all"),
                selectsAllByDefault: companyAttributes
                    .companyAttributes
                    .value?
                    .boolValue(forKey: "accounts.estatement.enrollAll.default") ?? false,
                viewDisclosureButtonText: l10nProvider.localize("edocs-selection.estatements.btn.view-disclosure"),
                logoImage: UIImage(named: "FullLogo"),
                paperlessRequestConfiguration: EDocsRequestConfiguration(
                    paperlessPrompt: false,
                    estatementPrompt: true
                )
            ),
            confirmationConfiguration: estatementTypeConfirmationConfig(sortKey: .estatements),
            disclosureConfiguration: EDocsDisclosureConfig(
                legalService: legalService,
                legalServiceType: .estatements,
                disclosureViewControllerFactory: disclosureViewControllerFactory,
                errorTitle: l10nProvider.localize("app.error.generic.title"),
                errorMessage: l10nProvider.localize("edocs-selection.estatements.disclosure.error")
            )
        )
    }

    public func noticesConfiguration() -> EDocsConfiguration {
        return EDocsConfiguration(
            accountSelectionConfiguration: EDocsAccountSelectionConfiguration(
                headerText: l10nProvider.localize("edocs-selection.notice.title"),
                infoLabelText: l10nProvider.localize("edocs-selection.notice.info.text"),
                submitButtonText: l10nProvider.localize("edocs-selection.notice.btn.yes"),
                declineButtonText: l10nProvider.localize("edocs-selection.notice.btn.no"),
                selectAllCheckboxTitle: l10nProvider.localize("edocs-selection.notice.btn.select-all"),
                selectsAllByDefault: companyAttributes
                    .companyAttributes
                    .value?
                    .boolValue(forKey: "accounts.notices.default.enabled") ?? false,
                viewDisclosureButtonText: l10nProvider.localize("edocs-selection.notice.btn.view-disclosure"),
                logoImage: UIImage(named: "FullLogo"),
                paperlessRequestConfiguration: EDocsRequestConfiguration(
                    paperlessPrompt: false,
                    estatementPrompt: true
                )
            ),
            confirmationConfiguration: EDocsConfirmationConfiguration(
                sortKey: .notices,
                sectionTitle: l10nProvider.localize("edocs-result.notice.header"),
                successTitle: l10nProvider.localize("edocs-result.notice.success"),
                failureTitle: l10nProvider.localize("edocs-result.notice.failure")
            ),
            disclosureConfiguration: EDocsDisclosureConfig(
                legalService: legalService,
                legalServiceType: .notices,
                disclosureViewControllerFactory: disclosureViewControllerFactory,
                errorTitle: l10nProvider.localize("app.error.generic.title"),
                errorMessage: l10nProvider.localize("edocs-selection.notice.disclosure.error")
            )
        )
    }

    public func taxDocsConfiguration() -> EDocsConfiguration {
        return EDocsConfiguration(
            accountSelectionConfiguration: EDocsAccountSelectionConfiguration(
                headerText: l10nProvider.localize("edocs-selection.tax.title"),
                infoLabelText: l10nProvider.localize("edocs-selection.tax.info.text"),
                submitButtonText: l10nProvider.localize("edocs-selection.tax.btn.yes"),
                declineButtonText: l10nProvider.localize("edocs-selection.tax.btn.no"),
                selectAllCheckboxTitle: l10nProvider.localize("edocs-selection.tax.checkbox"),
                selectsAllByDefault: companyAttributes
                    .companyAttributes
                    .value?
                    .boolValue(forKey: "user.etaxDocument.default.enabled") ?? false,
                viewDisclosureButtonText: l10nProvider.localize("edocs-selection.tax.btn.view-disclosure"),
                logoImage: UIImage(named: "FullLogo"),
                paperlessRequestConfiguration: EDocsRequestConfiguration(
                    paperlessPrompt: false,
                    estatementPrompt: false
                )
            ),
            confirmationConfiguration: EDocsConfirmationConfiguration(
                sortKey: .taxDocs,
                sectionTitle: l10nProvider.localize("edocs-result.tax.header"),
                successTitle: l10nProvider.localize("edocs-result.tax.success"),
                failureTitle: l10nProvider.localize("edocs-result.tax.failure")
            ),
            disclosureConfiguration: EDocsDisclosureConfig(
                legalService: legalService,
                legalServiceType: .taxDocs,
                disclosureViewControllerFactory: disclosureViewControllerFactory,
                errorTitle: l10nProvider.localize("app.error.generic.title"),
                errorMessage: l10nProvider.localize("edocs-selection.tax.disclosure.error")
            )
        )
    }

    private func estatementTypeConfirmationConfig(sortKey: EDocsSortKey) -> EDocsConfirmationConfiguration {
        return EDocsConfirmationConfiguration(
            sortKey: sortKey,
            sectionTitle: l10nProvider.localize("edocs-result.estatements.header"),
            successTitle: l10nProvider.localize("edocs-result.estatements.success"),
            failureTitle: l10nProvider.localize("edocs-result.estatements.failure")
        )
    }
}
