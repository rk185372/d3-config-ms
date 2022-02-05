//
//  AccountsViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/3/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import CompanyAttributes
import UIKit
import UITableViewPresentation
import Perform
import D3Accounts
import Utilities
import Analytics
import ShimmeringData
import ComponentKit
import Localization
import Logging
import Messages
import PresenterKit
import RxSwift
import Session
import Views
import Web
import InAppRatingApi

final class AccountsViewController: UIViewControllerComponent {

    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: UITableViewPresentableDataSource!
    private var headerView: ProfileHeaderView!
    private var accountSections: [AccountSection] = []
    private var alertsCount = 0
    private var approvalsCount = 0

    private let accountsService: AccountsService
    private let transactionsViewControllerFactory: TransactionsViewControllerFactory
    private let buttonPresenterFactory: ButtonPresenterFactory
    private let userSession: UserSession
    private let refreshControl = UIRefreshControl()
    private let companyAttributes: CompanyAttributesHolder
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let addOfflineAccountViewControllerFactory: AddOfflineAccountViewControllerFactory
    private let profileIconCoordinatorFactory: ProfileIconCoordinatorFactory
    private let profileIconCoordinator: ProfileIconCoordinator
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         accountsService: AccountsService,
         transactionsViewControllerFactory: TransactionsViewControllerFactory,
         buttonPresenterFactory: ButtonPresenterFactory,
         userSession: UserSession,
         companyAttributes: CompanyAttributesHolder,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory,
         addOfflineAccountViewControllerFactory: AddOfflineAccountViewControllerFactory,
         profileIconCoordinatorFactory: ProfileIconCoordinatorFactory) {
        self.accountsService = accountsService
        self.transactionsViewControllerFactory = transactionsViewControllerFactory
        self.buttonPresenterFactory = buttonPresenterFactory
        self.userSession = userSession
        self.companyAttributes = companyAttributes
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.addOfflineAccountViewControllerFactory = addOfflineAccountViewControllerFactory
        self.profileIconCoordinatorFactory = profileIconCoordinatorFactory
        self.profileIconCoordinator = profileIconCoordinatorFactory.create()

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AccountsPresentationBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        headerView = ProfileHeaderView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.bounds.width, height: 100)))
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        // TODO: The current l10n for this being used by the web has embeded html
        // to achieve the new line and bolding. We have to separate labels so
        // we will need to create an l10n for the welcome back text and use it here.
        headerView.titleLabel.text = "Welcome back,"

        // TODO: We are currently grabing the value out of the first user profiles
        // when we implement profile switching we will want to update this to use
        // the currently selected profile. 
        headerView.nameLabel.text = userSession.userProfiles.first?.firstName
        
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        headerView.profilePic.isHidden = view.traitCollection.preferredContentSizeCategory.isAccessibilitySize
        
        getAccounts()
        setupRefreshControl()
        setupProfileIcon()
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl(sender:)), for: .valueChanged)
    }

    private func setupProfileIcon() {
        navigationItem.rightBarButtonItem = profileIconCoordinator.profileIconComponent
        profileIconCoordinator.setupForViewController(self)
    }
    
    private func getAccounts() {
        setLoadingDataSource()
        self.tableView.backgroundView = nil

        accountsService
            .getAccounts()
            .subscribe({ [unowned self] event in
                switch event {
                case .success(let accountSections):
                    self.accountSections = accountSections
                    self.updateTableView(
                        given: accountSections,
                        contentSizeCategory: self.view.traitCollection.preferredContentSizeCategory
                    )
                    self.tableView.refreshControl = self.refreshControl
                    self.tableView.isScrollEnabled = true
                    self.tableView.refreshControl?.endRefreshing()
                case .error(let error):
                    log.error("Error fetching accounts: \(error)", context: error)
                    
                    self.dataSource.tableViewModel = []
                    let noItemsView = NoItemsView(frame: CGRect(origin: self.tableView.bounds.origin, size: self.tableView.bounds.size))
                    noItemsView.tryAgainButton.addTarget(self, action: #selector(self.tryAgainButtonTouched(_:)), for: .touchUpInside)
                    self.tableView.backgroundView = noItemsView

                    // Stop refreshing so that the refresh control hides and
                    // the header view returns to the top, then remove the refresh
                    // control so that it cannot be pulled in the error state.
                    // (We typically force the user to hit the provided retry button
                    // in error conditions rather than leaving the refresh control)
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.refreshControl = nil
                    self.tableView.isScrollEnabled = false
                }
            })
            .disposed(by: bag)
    }

    private func updateTableView(given accounts: [AccountSection], contentSizeCategory: UIContentSizeCategory) {
        let accountPresenterFactory: AccountPresenterFactory = contentSizeCategory.isAccessibilitySize
            ? ADAAccountPresenterFactory(l10nProvider: self.l10nProvider)
            : StandardAccountPresenterFactory(l10nProvider: l10nProvider)

        // TODO: Pending further API changes to the accounts_list_transformer, we will probably get the
        // two presenters (open a new account) and (add offline account) from that translation and will
        // no longer need to split these like this to insert them. 
        let sections = buildTableViewSections(for: accounts, withPresenterFactory: accountPresenterFactory)
        var internalSections = sections.filter({ section in
            guard let group = (section.rows.first?.base as? AccountPresenter)?.account.source else { return false }

            return group == "INTERNAL"
        })
        var externalSections = sections.filter({ section in
            guard let group = (section.rows.first?.base as? AccountPresenter)?.account.source else { return false }

            return group != "INTERNAL"
        })

        // If we should show new account opening add it here
        let shouldShowOpenNewAccount = companyAttributes
            .companyAttributes
            .value?
            .boolValue(forKey: "accounts.accountOpening.enabled") ?? false

        if shouldShowOpenNewAccount, let lastSection = internalSections.last {
            internalSections.removeLast()
            let new = copy(lastSection, addingRows: [AnyUITableViewPresentable(OpenANewAccountPresenter(delegate: self))])
            internalSections.append(new)
        }

        // The add an offline account button should still show even if there are no offline
        // accounts.
        if let lastExternalSection = externalSections.last {
            externalSections.removeLast()
            let new = copy(lastExternalSection, addingRows: [AnyUITableViewPresentable(getAddOfflineAccountPresenter())])
            externalSections.append(new)
        } else {
            let rows = [AnyUITableViewPresentable(getAddOfflineAccountPresenter())]

            let section = UITableViewSection(
                rows: rows,
                header: .none,
                footer: .blank
            )

            externalSections.append(section)
        }

        self.dataSource.tableViewModel = UITableViewModel(
            sections: internalSections + externalSections
        )
    }

    private func getAddOfflineAccountPresenter() -> ButtonPresenter {
        return ButtonPresenter(
            buttonTitle: l10nProvider.localize("accounts.btn.add-account"),
            style: .buttonOutlineOnDefault,
            clickListener: { [weak self] _ in
                guard let viewController = self?.addOfflineAccountViewControllerFactory.create() else { return }
                let navigationController = UINavigationControllerComponent(rootViewController: viewController)

                self?.present(navigationController, animated: true, completion: nil)
            }
        )
    }

    private func buildTableViewSections(for accounts: [AccountSection],
                                        withPresenterFactory presenterFactory: AccountPresenterFactory) -> [UITableViewSection] {
        return accounts.map { accountSection in
            var sectionHeader: AnyUITableViewHeaderFooterPresentable

            if UIDevice.current.userInterfaceIdiom == .pad {
                sectionHeader = AnyUITableViewHeaderFooterPresentable(
                    AccountsIPadSectionHeaderPresenter(title: l10nProvider.localize(accountSection.name))
                )
            } else {
                sectionHeader = AnyUITableViewHeaderFooterPresentable(
                    AccountsSectionHeaderPresenter(title: l10nProvider.localize(accountSection.name))
                )
            }

            return UITableViewSection(
                rows: accountSection.items.map({ account in presenterFactory.create(account: account) }),
                header: .presentable(sectionHeader),
                footer: .blank
            )
        }
    }

    private func copy(_ tableViewSection: UITableViewSection, addingRows newRows: [AnyUITableViewPresentable]) -> UITableViewSection {
        return UITableViewSection(
            rows: tableViewSection.rows + newRows,
            header: tableViewSection.header,
            footer: tableViewSection.footer
        )
    }
    
    @objc private func didPullRefreshControl(sender: UIRefreshControl) {
        getAccounts()
    }
    
    private func setLoadingDataSource() {
        dataSource.tableViewModel = .shimmeringDataModel
        
        tableView.reloadData()
    }

    @objc private func contentSizeCategoryDidChange(_ sender: Notification) {
        let contentSizeCategory = UIContentSizeCategory(rawValue: sender.userInfo!["UIContentSizeCategoryNewValueKey"] as! String)

        updateTableView(given: self.accountSections, contentSizeCategory: contentSizeCategory)
        headerView.profilePic.isHidden = self.view.traitCollection.preferredContentSizeCategory.isAccessibilitySize
    }

    @objc private func tryAgainButtonTouched(_ sender: UIButton) {
        getAccounts()
    }

    private func handleNewAccountResponse(_ response: OpenANewAccountResponse) {
        // Validate that the status is ready
        guard response.status == .ready else {
            showAccountOpeningError()
            return
        }

        let webViewController = externalWebViewControllerFactory.create(
            destination: .url(buildURL(from: response.redirect))
        )

        present(webViewController, animated: true) {
            self.cancelables.cancel()
        }
    }

    private func buildURL(from redirect: OpenANewAccountRedirect) -> URL {
        var components = URLComponents(string: redirect.url)!
        components.queryItems = redirect.fields.map { URLQueryItem(name: $0.0, value: $0.1 as? String) }

        return components.url!
    }

    private func showAccountOpeningError() {
        let alert = UIAlertController(
            title: l10nProvider.localize("accounts.open-account.error.redirect.title"),
            message: l10nProvider.localize("accounts.open-account.error.redirect.text"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default) { _ in
                self.cancelables.cancel()
            }
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
}

extension AccountsViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let account = (presentable.base as? AccountPresenter)?.account else { return }
        
        let transactionViewController = transactionsViewControllerFactory.create(account: account)
        navigationController?.pushViewController(transactionViewController, animated: true)
    }
}

extension AccountsViewController: OpenANewAccountPresenterDelegate {
    func openAccountButtonTouched(_ button: UIButtonComponent, inPresenter presenter: OpenANewAccountPresenter) {
        beginLoading(fromButton: button)

        accountsService
            .openExternalAccount()
            .subscribe(onSuccess: { [unowned self] response in
                self.handleNewAccountResponse(response)
            }, onError: { [unowned self] _ in
                self.showAccountOpeningError()
            })
            .disposed(by: bag)
    }
}

extension AccountsViewController: TrackableScreen {
    var screenName: String {
        return "Accounts"
    }
}
