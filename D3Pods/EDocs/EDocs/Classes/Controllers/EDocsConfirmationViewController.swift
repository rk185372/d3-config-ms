//
//  EDocsConfirmationViewController.swift
//  EDocs
//
//  Created by Chris Carranza on 1/18/18.
//

import Analytics
import ComponentKit
import Logging
import RxSwift
import ShimmeringData
import UIKit
import UITableViewPresentation

final class EDocsConfirmationViewController: UIViewControllerComponent, EDocsStepable {

    private struct OrderablePresentable {
        let sortKey: EDocsSortKey
        let element: AnyUITableViewPresentable
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var okButton: UIButtonComponent!

    var results: [EDocsSelectionResult] = []
    weak var edocsFlowDelegate: EDocsFlowDelegate?

    private let service: EDocsService
    private var dataSource: UITableViewPresentableDataSource!
    
    init(config: ComponentConfig, service: EDocsService) {
        self.service = service
        
        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: EDocsBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = UIImage(named: "FullLogo")
        okButton.setTitle(l10nProvider.localize("edocs-result.btn.done"), for: .normal)
        okButton.isEnabled = false

        dataSource = UITableViewPresentableDataSource(tableView: tableView)
        dataSource.tableViewModel = .shimmeringDataModel

        makeNetworkRequests()
    }

    func makeNetworkRequests() {
        var observables: [Observable<OrderablePresentable>] = []

        results.forEach { result in
            switch result {
            case .estatement(let accounts, let requestConfig, let confirmationConfig):
                observables.append(
                    handleEstatementNetworkRequest(
                        withAccounts: accounts,
                        requestConfig: requestConfig,
                        confirmationConfig: confirmationConfig
                    ).asObservable()
                )
            case .notices(let accounts, let confirmationConfig):
                observables.append(
                    handleNoticesNetworkRequest(for: accounts, confirmationConfig: confirmationConfig).asObservable()
                )
            case .taxDocs(let confirmationConfig):
                observables.append(
                    handleTaxDocsNetworkRequest(confirmationConfig: confirmationConfig).asObservable()
                )
            }
        }

        Observable
            .zip(observables)
            .subscribe({ [unowned self] event in
                switch event {
                case .next(let presentables):
                    self.updateTableView(
                        with: presentables.sorted(by: { $0.sortKey < $1.sortKey }).map({ $0.element })
                    )
                case .error:
                    // We should never get here because none of the observables being
                    // zipped here can fail. They will always result in an OrderablePresentable
                    fatalError("This should never fail")
                case .completed:
                    break
                }

            })
            .disposed(by: bag)
    }

    private func updateTableView(with presentables: [AnyUITableViewPresentable]) {
        let sectionHeader = EDocsAccountSelectionHeaderPresentable(
            title: l10nProvider.localize("edocs-result.title"),
            subtitle: l10nProvider.localize("edocs-result.subtitle")
        )

        let footer = InfoFooterPresenter(infoText: l10nProvider.localize("edocs-result.info"))

        let section = UITableViewSection(
            rows: presentables,
            header: .presentable(AnyUITableViewHeaderFooterPresentable(sectionHeader)),
            footer: .presentable(AnyUITableViewHeaderFooterPresentable(footer))
        )

        dataSource.tableViewModel = UITableViewModel(sections: [section])

        okButton.isEnabled = true
    }

    private func handleEstatementNetworkRequest(withAccounts accounts: [EDocsPromptAccount],
                                                requestConfig: EDocsRequestConfiguration,
                                                confirmationConfig: EDocsConfirmationConfiguration) -> Single<OrderablePresentable> {
        let request = UpdateDeliverySettings(
            electronicDocumentType: EDocsDocumentType.statement.rawValue,
            taxPreference: nil,
            accounts: accounts
        )
        
        return service
            .updateEDocPreferences(request: request, confirmationConfig: confirmationConfig)
            .map({ networkResult in
                switch networkResult {
                case .success(_, let confirmationConfig):
                    let presenter = EnrollmentResultPresenter(
                        successes: accounts,
                        failures: [],
                        confirmationConfig: confirmationConfig
                    )

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                case .failure(let confirmationConfig):
                    // This case only happens in the event of a network failure
                    // In that case we assume that all of the accounts we tried to
                    // enroll failed.
                    let presenter = EnrollmentResultPresenter(
                        successes: [],
                        failures: accounts,
                        confirmationConfig: confirmationConfig
                    )

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                }
            })
    }

    private func handleNoticesNetworkRequest(for accounts: [EDocsPromptAccount],
                                             confirmationConfig: EDocsConfirmationConfiguration) -> Single<OrderablePresentable> {
        let request = UpdateDeliverySettings(
            electronicDocumentType: EDocsDocumentType.notice.rawValue,
            taxPreference: nil,
            accounts: accounts
        )

        return service
            .updateEDocPreferences(request: request, confirmationConfig: confirmationConfig)
            .map({ networkResult in
                switch networkResult {
                case .success(_, let confirmationConfig):
                    let presenter = EnrollmentResultPresenter(
                        successes: accounts,
                        failures: [],
                        confirmationConfig: confirmationConfig
                    )

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                case .failure(let confirmationConfig):
                    let presenter = EnrollmentResultPresenter(
                        successes: [],
                        failures: accounts,
                        confirmationConfig: confirmationConfig
                    )

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                }
            })
    }

    private func handleTaxDocsNetworkRequest(confirmationConfig: EDocsConfirmationConfiguration) -> Single<OrderablePresentable> {
        let request = UpdateDeliverySettings(
            electronicDocumentType: EDocsDocumentType.tax.rawValue,
            taxPreference: "ELECTRONIC",
            accounts: []
        )

        return service
            .updateEDocPreferences(request: request, confirmationConfig: confirmationConfig)
            .map({ networkResult in
                switch networkResult {
                case .success(response: _, confirmationConfig: let confirmationConfig):
                    let presenter = TaxDocsEnrollmentResultPresenter(success: true, confirmationConfig: confirmationConfig)

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                case .failure(let confirmationConfig):
                    let presenter = TaxDocsEnrollmentResultPresenter(success: false, confirmationConfig: confirmationConfig)

                    return OrderablePresentable(
                        sortKey: confirmationConfig.sortKey,
                        element: AnyUITableViewPresentable(presenter)
                    )
                }
            })
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        edocsFlowDelegate?.edocsFlowAdvance()
    }
}

extension EDocsConfirmationViewController: TrackableScreen {
    var screenName: String {
        return "LoginFlow/Paperless"
    }
}
