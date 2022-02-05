//
//  TaxDocsEnrollmentViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/18/19.
//

import CompanyAttributes
import ComponentKit
import Foundation
import LegalContent
import Localization
import UIKit
import UITableViewPresentation

final class TaxDocsEnrollmentViewController: EDocsGenericAccountSelectionViewController {

    private let edocsPreferencesConfig: EDocsPreferencesConfig?

    private lazy var enrollInTaxDocsCheckbox: SelectAllPresenter = {
        return SelectAllPresenter(
            checkboxTitle: accountSelectionConfig.selectAllCheckboxTitle, l10nProvider: l10nProvider
        )
    }()

    init(accountSelectionConfig: EDocsAccountSelectionConfiguration,
         edocsPreferencesConfig: EDocsPreferencesConfig? = nil,
         resultProvider: EDocsResultProvider,
         service: EDocsService,
         disclosureConfig: EDocsDisclosureConfig,
         companyAttributes: CompanyAttributesHolder,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {

        self.edocsPreferencesConfig = edocsPreferencesConfig

        super.init(
            accountSelectionConfig: accountSelectionConfig,
            resultProvider: resultProvider,
            service: service,
            disclosureConfig: disclosureConfig,
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = EDocsAccountSelectionHeaderPresentable(
            title: accountSelectionConfig.headerText,
            subtitle: accountSelectionConfig.infoLabelText
        )

        let footer = DisclosureButtonFooterPresenter(
            disclosureButtonTitle: accountSelectionConfig.viewDisclosureButtonText,
            delegate: self
        )

        dataSource = UITableViewPresentableDataSource(
            tableView: tableView,
            delegate: nil,
            tableViewModel: UITableViewModel(
                sections: [
                    UITableViewSection(
                        rows: [enrollInTaxDocsCheckbox],
                        header: .presentable(
                            AnyUITableViewHeaderFooterPresentable(header)
                        ),
                        footer: .presentable(
                            AnyUITableViewHeaderFooterPresentable(footer)
                        )
                    )
                ]
            )
        )

        enrollInTaxDocsCheckbox
            .rx
            .isSelected
            .subscribe(onNext: { [unowned self] isSelected in
                self.goPaperlessButton.isEnabled = isSelected
            })
            .disposed(by: bag)

        if accountSelectionConfig.selectsAllByDefault {
            enrollInTaxDocsCheckbox.isSelected = true
        }
    }

    override func acceptButtonTouched(_ sender: UIButtonComponent) {
        beginLoading(fromButton: sender)

        edocsFlowDelegate?.edocsEnrollmentAccepted(
            withResult: resultProvider.getEDocsResult(given: [])
        )
    }

    override func noThanksButtonTouched(_ sender: UIButton) {
        cancelables.cancel()

        if let config = edocsPreferencesConfig {
            _ = service
                .declineEDocs(for: config.electronicDocumentType)
                .subscribe()
        }

        edocsFlowDelegate?.edocsFlowAdvance()
    }
}
