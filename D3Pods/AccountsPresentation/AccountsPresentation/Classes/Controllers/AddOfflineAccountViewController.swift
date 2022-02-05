//
//  AddOfflineAccountViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/15/19.
//

import D3Accounts
import ComponentKit
import Localization
import Foundation
import RxSwift
import ShimmeringData
import UIKit
import Utilities
import ViewPresentable

final class AddOfflineAccountViewController: UIViewControllerComponent {
    @IBOutlet weak var stackView: UIStackView!

    private let serviceItem: AccountsService
    private var offlineAccount: OfflineAccount?
    private var presenters: [AnyViewPresentable] = []

    init(serviceItem: AccountsService,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.serviceItem = serviceItem

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "AddOfflineAccountViewController",
            bundle: AccountsPresentationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // we are adding our own custom close button as the right bar button item of the navigation item.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "CloseIcon", in: AccountsPresentationBundle.bundle, compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(closeButtonTouched(_:))
        )

        navigationStyleItem.hideShadowImage()
        addLoadingView()
        getAccountProducts()
    }

    private func getAccountProducts() {
        serviceItem
            .getOfflineAccountProducts()
            .subscribe(onSuccess: { [unowned self] products in
                guard !products.isEmpty else {
                    self.showProductsFailedToLoadError()
                    return
                }

                self.initializePresenters(with: products)
                self.removeLoadingView()
                self.populateStackView()
                self.offlineAccount = OfflineAccount(
                    name: "",
                    nickname: nil,
                    balance: 0.0,
                    source: "OFFLINE",
                    status: "OPEN",
                    associated: true,
                    product: products.first!
                )
            }, onError: { [unowned self] _ in
                self.showProductsFailedToLoadError()
            })
            .disposed(by: bag)
    }

    private func initializePresenters(with products: [RawAccountProduct]) {
        presenters = [
            AnyViewPresentable(
                AccountTypePresenter(
                    accountTypeHolder: AccountTypeHolder(choices: products),
                    componentStyleProvider: componentStyleProvider,
                    l10nProvider: l10nProvider,
                    style: .selectionBoxOnSecondary,
                    delegate: self
                )
            ),
            AnyViewPresentable(
                AccountNamePresenter(
                    styleKey: .titledTextFieldOnSecondary,
                    componentStyleProvider: componentStyleProvider,
                    l10nProvider: l10nProvider,
                    delegate: self
                )
            ),
            AnyViewPresentable(
                AccountBalancePresenter(
                    styleKey: .titledTextFieldOnSecondary,
                    componentStyleProvider: componentStyleProvider,
                    l10nProvider: l10nProvider,
                    delegate: self
                )
            ),
            AnyViewPresentable(
                ButtonViewPresenter(
                    styleKey: .buttonCta,
                    componentStyleProvider: componentStyleProvider,
                    buttonTitle: l10nProvider.localize("accounts.btn.offline.save"),
                    onSelect: saveButtonTouched
                )
            ),
            AnyViewPresentable(
                ButtonViewPresenter(
                    styleKey: .buttonOutlineOnSecondary,
                    componentStyleProvider: componentStyleProvider,
                    buttonTitle: l10nProvider.localize("accounts.btn.offline.cancel"),
                    onSelect: cancelButtonTouched
                )
            )
        ]
    }

    private func addLoadingView() {
        let loadingViewPresenter = ShimmeringViewPresenter<AddOfflineAccountsLoadingView>(
            bundle: AccountsPresentationBundle.bundle,
            styleKey: .shimmeringViewOnSecondary,
            componentStyleProvider: componentStyleProvider
        )

        let loadingView = loadingViewPresenter.createView()
        loadingViewPresenter.configure(view: loadingView)

        stackView.addArrangedSubview(loadingView)
    }

    private func removeLoadingView() {
        stackView.subviews.forEach { view in
            if view is AddOfflineAccountsLoadingView {
                view.removeFromSuperview()
            }
        }
    }

    private func populateStackView() {
        presenters.forEach { presentable in
            let view = presentable.createView()
            presentable.configure(view: view)
            self.stackView.addArrangedSubview(view)
        }
    }

    private func showProductsFailedToLoadError() {
        let alert = UIAlertController(
            title: l10nProvider.localize("app.error.generic.title"),
            message: l10nProvider.localize("offline-account.loading.error"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        )

        present(alert, animated: true, completion: nil)
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: nil,
            message: l10nProvider.localize("accounts.add.save.success"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        )

        present(alert, animated: true, completion: nil)
    }

    private func showSaveErrorAlert() {
        let alert = UIAlertController(
            title: l10nProvider.localize("app.error.generic.title"),
            message: l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default)
        )

        present(alert, animated: true, completion: nil)
    }

    private func beginLoading(fromButton button: UIButtonComponent) {
        cancelables.cancel()

        let controls = view.descendantViews.compactMap { $0 as? UIControl }

        button.isLoading = true
        controls.forEach { $0.isEnabled = false }

        cancelables.insert {
            button.isLoading = false
            controls.forEach { $0.isEnabled = true }
        }
    }

    private func saveButtonTouched(_ sender: UIButtonComponent) {
        guard let account = offlineAccount else { return }
        beginLoading(fromButton: sender)

        serviceItem
            .saveOfflineAccount(account: account)
            .subscribe { [unowned self] result in
                switch result {
                case .success:
                    self.showSuccessAlert()
                case .error:
                    self.showSaveErrorAlert()
                }
                self.cancelables.cancel()
            }
            .disposed(by: bag)
    }

    private func cancelButtonTouched(_ sender: UIButtonComponent) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func closeButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddOfflineAccountViewController: AccountTypePresenterDelegate {
    func accountTypePresenter(_ presenter: AccountTypePresenter, selectedItemChangedTo selectedItem: RawAccountProduct) {
        offlineAccount?.product = selectedItem
    }
}

extension AddOfflineAccountViewController: AccountNamePresenterDelegate {
    func accountNamePresenter(_ presenter: AccountNamePresenter, didUpdateNameTo name: String) {
        offlineAccount?.name = name
    }
}

extension AddOfflineAccountViewController: AccountBalancePresenterDelegate {
    func accountBalancePresenter(_ presenter: AccountBalancePresenter, balanceChangedTo balance: Decimal) {
        offlineAccount?.balance = balance
    }
}
