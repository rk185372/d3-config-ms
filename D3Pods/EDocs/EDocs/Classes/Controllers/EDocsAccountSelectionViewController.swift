//
//  EDocsAccountSelectionViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/7/17.
//

import Analytics
import ComponentKit
import Foundation
import LegalContent
import Logging
import RxRelay
import RxSwift
import UIKit
import UITableViewPresentation
import Utilities

class EDocsAccountSelectionViewController: EDocsGenericAccountSelectionViewController {

    let viewModel: AccountSelectionViewModel

    private let preferencesConfig: EDocsPreferencesConfig?
    
    init(config: ComponentConfig,
         accountSelectionConfig: EDocsAccountSelectionConfiguration,
         edocsPreferencesConfig: EDocsPreferencesConfig? = nil,
         resultProvider: EDocsResultProvider,
         viewModel: AccountSelectionViewModel,
         service: EDocsService,
         disclosureConfig: EDocsDisclosureConfig) {
        self.preferencesConfig = edocsPreferencesConfig
        self.viewModel = viewModel

        super.init(
            accountSelectionConfig: accountSelectionConfig,
            resultProvider: resultProvider,
            service: service,
            disclosureConfig: disclosureConfig,
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectAllPresenter = SelectAllPresenter(
            checkboxTitle: accountSelectionConfig.selectAllCheckboxTitle,
            l10nProvider: l10nProvider
        )

        selectAllPresenter
            .rx
            .checkboxTapped
            .subscribe(onNext: { [unowned self] selected in
                self.viewModel
                    .presenters
                    .forEach {
                        $0.isSelected = selected
                }
            })
            .disposed(by: bag)

        let presenters: [AnyUITableViewPresentable] = [AnyUITableViewPresentable(selectAllPresenter)]
            + viewModel.presenters.map { AnyUITableViewPresentable($0) }
        
        let section = UITableViewSection(
            rows: presenters,
            header: .presentable(
                AnyUITableViewHeaderFooterPresentable(
                    EDocsAccountSelectionHeaderPresentable(
                        title: accountSelectionConfig.headerText,
                        subtitle: accountSelectionConfig.infoLabelText
                    )
                )
            ),
            footer: .presentable(
                AnyUITableViewHeaderFooterPresentable(
                    DisclosureButtonFooterPresenter(
                        disclosureButtonTitle: accountSelectionConfig.viewDisclosureButtonText,
                        delegate: self
                    )
                )
            )
        )

        dataSource = UITableViewPresentableDataSource(
            tableView: tableView,
            delegate: self,
            tableViewModel: UITableViewModel(sections: [section])
        )
        
        isLoading
            .map { !$0 }
            .bind(to: noThanksButton.rx.isEnabled)
            .disposed(by: bag)
        
        let anyAccountsSelected = Observable
            .combineLatest(viewModel.presenters.map { $0.rx.isSelected })
            .map { $0.contains(true) }
        
        Observable.combineLatest(anyAccountsSelected, isLoading)
            .map { (anyAccountsSelected, isLoading) in
                return anyAccountsSelected && !isLoading
            }
            .bind(to: goPaperlessButton.rx.isEnabled)
            .disposed(by: bag)
        
        // Listens for all accounts "selected" property to determine if
        // the select all checkbox should be checked.
        Observable
            .combineLatest(viewModel.presenters.map { $0.rx.isSelected })
            .map { !$0.contains(false) }
            .subscribe(onNext: { (allSelected) in
                selectAllPresenter.isSelected = allSelected
            })
            .disposed(by: bag)

        if accountSelectionConfig.selectsAllByDefault {
            viewModel
                .presenters
                .forEach {
                    $0.isSelected = true
            }
        }
    }

    override func acceptButtonTouched(_ sender: UIButtonComponent) {
        beginLoading(fromButton: sender)

        let selectedAccounts = viewModel
            .presenters
            .filter({ $0.isSelected })
            .map({ $0.account })

        edocsFlowDelegate?.edocsEnrollmentAccepted(
            withResult: resultProvider.getEDocsResult(given: selectedAccounts)
        )
    }

    override func noThanksButtonTouched(_ sender: UIButton) {
        cancelables.cancel()

        // We will fire off the decline here and forget about it as we don't want
        // to stop the user in the event the decline fails.
        if let config = preferencesConfig {
            _ = service
                .declineEDocs(for: config.electronicDocumentType)
                .subscribe()
        }

        edocsFlowDelegate?.edocsFlowAdvance()
    }
}

extension EDocsAccountSelectionViewController: TrackableScreen {
    var screenName: String {
        return "LoginFlow/Paperless"
    }
}

extension EDocsAccountSelectionViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        guard let presentable = presentable.base as? EDocsPromptAccountPresenter else { return }
        
        presentable.isSelected.toggle()
    }
}
