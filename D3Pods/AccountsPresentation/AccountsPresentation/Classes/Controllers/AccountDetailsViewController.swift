//
//  AccountDetailsViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/14/18.
//

import D3Accounts
import Foundation
import Network
import UIKit
import UITableViewPresentation
import Utilities
import ComponentKit
import Localization
import Logging
import RxSwift
import Views
import Analytics

final class AccountDetailsViewController: UIViewControllerComponent {

    @IBOutlet weak var tableView: UITableView!

    private let accountListItem: AccountListItem
    private let serviceItem: AccountsService
    private let cardControlsViewControllerFactory: CardControlsViewControllerFactory
    private let stopPaymentViewControllerFactory: StopPaymentViewControllerFactory

    private var account: Account!
    private var dataSource: UITableViewPresentableDataSource!
    private var tableHeader: AccountDetailsHeader!
    private var headerIsExpanded = false
    private var attributes: [AccountAttribute] = []

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         accountListItem: AccountListItem,
         serviceItem: AccountsService,
         cardControlsViewControllerFactory: CardControlsViewControllerFactory,
         stopPaymentViewControllerFactory: StopPaymentViewControllerFactory) {
        self.accountListItem = accountListItem
        self.serviceItem = serviceItem
        self.cardControlsViewControllerFactory = cardControlsViewControllerFactory
        self.stopPaymentViewControllerFactory = stopPaymentViewControllerFactory
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AccountsPresentationBundle.bundle
        )

        // We want to set the back bar button item to one with no title so that in the AccountDetailsViewController, the back
        // bar button item has no title.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferentContentSizeCategoryChanged(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        title = "Manage Account"
        navigationStyleItem.hideShadowImage()
        
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self, tableViewModel: [])

        setupAccountDetailsHeaderView()

        loadAccountDetails()
        loadAccountAttributes()
    }

    private func setupAccountDetailsHeaderView() {
        // Setup expandable table view header this will either be the StandardAccountDetailsHeader
        // or the ADAAccountDetailsHeader based on the preferred content size categor.
        if view.traitCollection.preferredContentSizeCategory.isAccessibilitySize {
            tableHeader = ADAAccountDetailsHeader(
                frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 375.0))
            ) as AccountDetailsHeader
        } else {
            tableHeader = StandardAccountDetailsHeader(
                frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 230.0))
            ) as AccountDetailsHeader
        }

        if let account = account {
            updateViewController(with: account)
        }

        if !attributes.isEmpty {
            addAttributesToHeaderView()
        }

        tableView.tableHeaderView = tableHeader
    }

    private func loadAccountDetails() {
        // We want to make sure that the table view's background view is nil
        // in case we had set it during a failed to load condition
        tableView.backgroundView = nil

        // Create the loading header to be shown while the network request is out.
        let loadingHeader = ShimmeringAccountDetailsHeader(
            frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 230.0))
        )

        // Set the table view's tableHeaderView to the loading header the model to the loading
        // model until the network request returns.
        tableView.tableHeaderView = loadingHeader
        dataSource.tableViewModel = .shimmeringDataModel

        // Make service request to get the account
        serviceItem
            .getAccount(withId: accountListItem.id)
            .subscribe(onSuccess: { [unowned self] account in
                self.account = account
                self.updateViewController(with: account)

                }, onError: { [unowned self] error in
                    log.error("Error fetching account details: \(error)", context: error)
                    
                    // We add the empty cell here to avoid the table view
                    // showing rows and cell dividers with no data.
                    self.dataSource.tableViewModel = [
                        UITableViewSection(rows: [EmptyCellPresenter()], footer: .blank)
                    ]
                    let noItemsView = NoItemsView()
                    noItemsView.infoLabel.text = "Failed to load account details."
                    noItemsView.tryAgainButton.addTarget(self, action: #selector(self.tryAgainButtonTouched(_:)), for: .touchUpInside)

                    // We want to remove the table view's header and set its background
                    // to the not items view.
                    self.tableView.tableHeaderView = nil
                    self.tableView.backgroundView = noItemsView
            })
            .disposed(by: bag)
    }

    private func loadAccountAttributes() {
        // We want to add an activity indicator here so that if the user
        // expands the header view before the account attributes are loaded,
        // they see that the data is loading.
        self.addActivityIndicatorToHeaderView()

        // Make service request to get the account attributes.
        serviceItem
            .getAccountAttributes(forAccountWithId: accountListItem.id)
            .subscribe(onSuccess: { [unowned self] attributes in
                self.attributes = attributes
                self.addAttributesToHeaderView()

                }, onError: { [unowned self] _ in
                    self.addErrorMessageToHeaderView()
            })
            .disposed(by: bag)
    }

    private func updateViewController(with account: Account) {
        // We are messaging the date here so that it appears in a format with <month>.<day>
        // i.e. 2.14.
        let date = ISO8601DateFormatter.longForm.date(from: account.lastSyncTime) ?? Date()
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        let dateString = "\(components.month!).\(components.day!)"

        // Format the balance and available balance.
        let balance = NumberFormatter.currencyFormatter(currencyCode: account.currencyCode)
            .string(from: account.balance) ?? ""

        // Grab the last five digits of the account number so that it is all that is shown.
        let accountNumber = String(account.accountNumber.suffix(5))

        tableHeader.updateView(
            withName: account.displayableName,
            balance: balance,
            accountNumber: accountNumber,
            status: account.status,
            lastUpdated: dateString
        )

        // Create the view controller buttons from the information returned with the Account object.
        let buttonConfigs = getAccountDetailsButtons(from: account)
        let buttonPresenters = getAccountDetailsButtonPresenters(from: buttonConfigs)

        // Create the view controller switches from teh information returned with the Account objec.
        let toggleConfigs = getAccountDetailsToggles(from: account)
        let togglePresenters = getAccountDetailsTogglePresenters(from: toggleConfigs)

        // Setup self as the target from the view controller header's expand and collapse button.
        tableView.tableHeaderView = tableHeader
        tableHeader.expandAndCollapseButton.addTarget(self, action: #selector(expandAndCollapseButtonTouched(_:)), for: .touchUpInside)

        // Create and update the dataSource's table view model.
        // We are using an empty cell at the bottom of the table view
        // to get the cell divider under the last element.
        dataSource.tableViewModel = [
            UITableViewSection(rows: buttonPresenters),
            UITableViewSection(rows: togglePresenters),
            UITableViewSection(rows: [EmptyCellPresenter()], footer: .blank)
        ]
    }

    private func addActivityIndicatorToHeaderView() {
        let loadingView = ADALoadingView(frame: .zero)
        loadingView.activityIndicator.startAnimating()
        tableHeader.stackView.addArrangedSubview(loadingView)
    }

    private func addAttributesToHeaderView() {
        // At this point there is probably an activity indicator in the header view's
        // stack view so we want to remove any subviews of the stack view.
        tableHeader.stackView.removeAllViews()

        // Map all of the attributes to an AccountAttributesView.
        // If we have an ADA content category size we use the ADAAccountAttributesView
        // otherwise we use the StandardAccountAttributesView.
        let views = attributes.map { (attribute) -> AccountAttributesView in
            var view: AccountAttributesView

            if self.view.traitCollection.preferredContentSizeCategory.isAccessibilitySize {
                view = ADAAccountAttributesView(frame: .zero)
            } else {
                view = StandardAccountAttributesView(frame: .zero)
            }

            view.attributeLabel.text = attribute.name.convertToTitle() + ":"
            view.valueLabel.text = attribute.value

            return view
        }

        // Loop through the array of views and add each to the header's stack view.
        for view in views {
            tableHeader.stackView.addArrangedSubview(view as! UIView)
        }

        // This is a special case of the header being expanded when the account.
        // attributes response returns and this method is called. In this case,
        // we have just populated the headerView's stack view so we want to animate
        // the header again so that it opens the rest of the way to accomadate the attributes.
        if headerIsExpanded {
            tableHeader.animateHeader(for: self, with: tableView, settingHeaderToExpanded: true)
        }
    }

    private func addErrorMessageToHeaderView() {
        // At this point there is probably an activity indicator in the header view's
        // stack view so we want to remove any subviews of the stack view.
        tableHeader.stackView.removeAllViews()

        let errorMessageView = ErrorMessageView(frame: .zero)
        errorMessageView.messageLabel.text = "Error loading account attributes."
        
        tableHeader.stackView.addArrangedSubview(errorMessageView)

        // This is a special case of the header being expanded when the account.
        // attributes response fails and this method is called. In this case,
        // we have just populated the headerView's stack view so we want to animate
        // the header again so that it opens the rest of the way to accomadate the error message.
        if headerIsExpanded {
            tableHeader.animateHeader(for: self, with: tableView, settingHeaderToExpanded: true)
        }
    }

    private func updateHeaderView(settingHeaderToExpanded expanded: Bool) {
        tableHeader.animateHeader(for: self, with: tableView, settingHeaderToExpanded: expanded)

    }

    @objc private func preferentContentSizeCategoryChanged(_ sender: Notification) {
        setupAccountDetailsHeaderView()
    }

    @objc private func expandAndCollapseButtonTouched(_ sender: UIButton) {
        if headerIsExpanded {
            updateHeaderView(settingHeaderToExpanded: false)
        } else {
            updateHeaderView(settingHeaderToExpanded: true)
        }

        self.headerIsExpanded = !self.headerIsExpanded
    }

    @objc private func tryAgainButtonTouched(_ sender: UIButton) {
        loadAccountDetails()
    }

    @objc private func cardControlsButtonTouched(_ sender: UIButton) {
        let controller = cardControlsViewControllerFactory.create(account: account)
        let navController = UINavigationControllerComponent(rootViewController: controller)

        present(navController, animated: true, completion: nil)
    }

    @objc private func orderChecksButtonTouched(_ sender: UIButton) {
        print("Order Checks Touched")
    }

    @objc private func overdraftEnrollmentButtonTouched(_ sender: UIButton) {
        print("Overdraft Enrollment Touched")
    }

    @objc private func stopPaymentButtonTouched(_ sender: UIButton) {
        let controller = stopPaymentViewControllerFactory.create(account: account)
        let navController = UINavigationControllerComponent(rootViewController: controller)

        present(navController, animated: true, completion: nil)
    }

    @objc private func brokerageAccessButtonTouched(_ sender: UIButton) {
        print("Brokerage Access Touched")
    }

    @objc private func hideAccountSwitchChanged(_ sender: UISwitch) {
        print("Hide Account Toggle Changed")
    }

    @objc private func excludeAccountSwitchChanged(_ sender: UISwitch) {
        print("Exclude Accuont Toggle Changed")
    }
}

extension AccountDetailsViewController: TrackableScreen {
    var screenName: String {
        return "Account Details"
    }
}

extension AccountDetailsViewController {
    private func getAccountDetailsButtons(from account: Account) -> [AccountDetailsButtonConfig] {
        var buttonConfigs: [AccountDetailsButtonConfig] = []

        if account.capabilities.eligibleForCards {
            let config = AccountDetailsButtonConfig(
                title: l10nProvider.localize("card-controls.dashboard.title"),
                target: self,
                action: #selector(cardControlsButtonTouched(_:)),
                controlEvent: .touchUpInside
            )
            buttonConfigs.append(config)
        }

        if account.capabilities.allowCheckOrders {
            let config = AccountDetailsButtonConfig(
                title: l10nProvider.localize("accounts.btn.order-checks"),
                target: self,
                action: #selector(orderChecksButtonTouched(_:)),
                controlEvent: .touchUpInside
            )
            buttonConfigs.append(config)
        }

        if account.capabilities.overdraftProtection {
            let config = AccountDetailsButtonConfig(
                title: account.overdraft.isEnrolledInOverdraftProtection
                    ? l10nProvider.localize("reg-e.btn.overdraft-unenrollment")
                    : l10nProvider.localize("reg-e.btn.overdraft-enrollment"),
                target: self,
                action: #selector(overdraftEnrollmentButtonTouched(_:)),
                controlEvent: .touchUpInside
            )
            buttonConfigs.append(config)
        }

        if account.capabilities.stopPayment {
            let config = AccountDetailsButtonConfig(
                title: l10nProvider.localize("accounts.btn.stop-payment"),
                target: self,
                action: #selector(stopPaymentButtonTouched(_:)),
                controlEvent: .touchUpInside
            )
            buttonConfigs.append(config)
        }

        if account.capabilities.allowBrokerageAccess {
            let config = AccountDetailsButtonConfig(
                title: l10nProvider.localize("accounts.btn.brokerage-access"),
                target: self,
                action: #selector(brokerageAccessButtonTouched(_:)),
                controlEvent: .touchUpInside
            )
            buttonConfigs.append(config)
        }

        return buttonConfigs
    }

    private func getAccountDetailsButtonPresenters(from configurations: [AccountDetailsButtonConfig]) -> [AccountDetailsButtonPresenter] {
        var presenters: [AccountDetailsButtonPresenter] = []

        // We are itterating over this array by two and, if there is a value at the current index (i), as well as a next value,
        // we will create an AccountDetailsButtonPresenter from the config at both the current index and the next index (i+1).
        // If there is not a value at the next index (i+1), we will create the AccountDetailsButtonPresenter with
        // its left button configuration being the configuration at the current index and the right button configuration
        // being nil.
        for i in stride(from: 0, to: configurations.count, by: 2) {
            if i + 1 <= configurations.count - 1 {
                presenters.append(
                    AccountDetailsButtonPresenter(leftButtonConfig: configurations[i], rightButtonConfig: configurations[i + 1])
                )
            } else {
                presenters.append(
                    AccountDetailsButtonPresenter(leftButtonConfig: configurations[i], rightButtonConfig: nil)
                )
            }
        }

        return presenters
    }

    private func getAccountDetailsToggles(from account: Account) -> [AccountDetailsButtonConfig] {
        var configs: [AccountDetailsButtonConfig] = []

        configs.append(
            AccountDetailsButtonConfig(
                title: "Hide Account",
                target: self,
                action: #selector(hideAccountSwitchChanged(_:)),
                controlEvent: .valueChanged,
                isOn: account.hidden
            )
        )

        configs.append(
            AccountDetailsButtonConfig(
                title: "Exclude Account",
                target: self,
                action: #selector(excludeAccountSwitchChanged(_:)),
                controlEvent: .valueChanged,
                isOn: account.excluded
            )
        )

        return configs
    }

    private func getAccountDetailsTogglePresenters(from toggleConfigs: [AccountDetailsButtonConfig]) -> [AccountDetailsTogglePresenter] {
        var presenters: [AccountDetailsTogglePresenter] = []

        for config in toggleConfigs {
            presenters.append(AccountDetailsTogglePresenter(toggleConfig: config))
        }

        return presenters
    }
}

extension AccountDetailsViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {}

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We originally take the NavigationBar's shadow image away and, when the user scrolls,
        // we put the shadow image back. If the table view's content offset is zero we want the
        // shadow image removed. Otherwise, we want the shadow image in place. 
        if scrollView.contentOffset.y == 0 {
            navigationStyleItem.hideShadowImage()
        } else {
            navigationStyleItem.showShadowImage()
        }
    }
}
