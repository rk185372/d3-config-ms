//
//  EDocsGenericAccountSelectionViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/18/19.
//

import ComponentKit
import Foundation
import LegalContent
import Localization
import RxRelay
import RxSwift
import UITableViewPresentation

class EDocsGenericAccountSelectionViewController: UIViewControllerComponent, EDocsStepable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goPaperlessButton: UIButtonComponent!
    @IBOutlet weak var noThanksButton: UIButtonComponent!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var headerView: UIViewComponent!
    
    weak var edocsFlowDelegate: EDocsFlowDelegate?

    let accountSelectionConfig: EDocsAccountSelectionConfiguration
    let resultProvider: EDocsResultProvider
    let service: EDocsService
    let disclosureConfig: EDocsDisclosureConfig
    let isLoading = BehaviorRelay(value: false)

    var dataSource: UITableViewPresentableDataSource!

    init(accountSelectionConfig: EDocsAccountSelectionConfiguration,
         resultProvider: EDocsResultProvider,
         service: EDocsService,
         disclosureConfig: EDocsDisclosureConfig,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.accountSelectionConfig = accountSelectionConfig
        self.resultProvider = resultProvider
        self.service = service
        self.disclosureConfig = disclosureConfig

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "EDocsGenericAccountSelectionViewController",
            bundle: EDocsBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.image = accountSelectionConfig.logoImage
        goPaperlessButton.setTitle(accountSelectionConfig.submitButtonText, for: .normal)
        noThanksButton.setTitle(accountSelectionConfig.declineButtonText, for: .normal)
    }

    private func beginLoading(fromButton button: UIButtonComponent) {
        cancelables.cancel()

        button.isLoading = true
        isLoading.accept(true)

        cancelables.insert { [weak self] in
            button.isLoading = false
            self?.isLoading.accept(false)
        }
    }

    func showDisclosure() {
        cancelables.cancel()

        let disclosure = disclosureConfig
            .legalService
            .retrieveDisclosure(legalServiceType: disclosureConfig.legalServiceType)
            .map({ $0.content })

        let disclosureViewController = disclosureConfig
            .disclosureViewControllerFactory
            .create(disclosure: disclosure, errorTitle: disclosureConfig.errorTitle, errorMessage: disclosureConfig.errorMessage)

        disclosureViewController.delegate = self
        disclosureViewController.modalPresentationStyle = .custom
        disclosureViewController.transitioningDelegate = self

        self.present(disclosureViewController, animated: true)
    }

    /// Action method for user touches to the "Submit Button".
    /// This method should be implemented by the subclass.
    /// - Parameter sender: `UIButtonComponent` triggering the action.
    @IBAction func acceptButtonTouched(_ sender: UIButtonComponent) {}

    /// Action method for user touches to the "Decline Button".
    /// This method should be implemented by the subclass however,
    /// A default implementation is provided that cancels cancelables,
    /// uses the service to decline going paperless and advances the flow.
    /// When overriding this method, the super implementation should not be called.
    /// - Parameter sender: `UIButtonComponent` triggering the action.
    @IBAction func noThanksButtonTouched(_ sender: UIButton) {}
}

extension EDocsGenericAccountSelectionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DisclosurePresentationController(
            presentedViewController: presented,
            presenting: presenting,
            topInset: headerView.frame.height
        )
    }
}

extension EDocsGenericAccountSelectionViewController: DisclosureViewControllerDelegate {
    func disclosureViewController(_ viewController: DisclosureViewController, dismissedByAccepting accepted: Bool) {
        dismiss(animated: true, completion: nil)
    }
}

extension EDocsGenericAccountSelectionViewController: DisclosureButtonFooterDelegate {
    func disclosureButtonTouched(_ sender: UIButtonComponent) {
        showDisclosure()
    }
}
