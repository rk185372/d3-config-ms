//
//  MenuInterfaceController.swift
//  D3 Banking Watchkit App Extension
//
//  Created by Branden Smith on 10/9/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import CompanyAttributes
import Dip
import Foundation
import Localization
import Logging
import RxRelay
import RxSwift
import Utilities
import WatchKit

class MenuInterfaceController: WKInterfaceController {
    enum RowType: Int {
        case accountBalance
        case transaction
        case location
        case customerService

        var identifier: String {
            switch self {
            case .accountBalance: return "AccountBalanceRow"
            case .transaction: return "TransactionRow"
            case .location: return "LocationRow"
            case .customerService: return "CustomerServiceRow"
            }
        }
    }

    let bag: DisposeBag = DisposeBag()

    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var menuTable: WKInterfaceTable!

    var l10nProvider: L10nProvider!
    var settingsService: SettingsService!
    var task: URLSessionDataTask?

    private let accountsRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let locationsRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let customerServiceRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    var menuRows = [RowType]()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // TODO: Find a way to inject the dependency container or even the l10n provider.
        l10nProvider = try! DependencyContainer.shared.resolve()
        settingsService = try! DependencyContainer.shared.resolve()

        if let bundleName = Bundle.main.stringValueForKey("CFBundleName") {
            setTitle(bundleName)
        }

        subscribeToAttributesChanges()
        getCompanyAttributes()

        errorLabel.setText(l10nProvider.localize("watch.error.server-unavailable"))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(watchAppDidBecomeActive(_:)),
            name: .watchAppDidBecomeActive,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadComponents(_:)),
            name: .reloadWatchComponentsNotification,
            object: nil
        )
    }

    private func subscribeToAttributesChanges() {
        accountsRelay.combinePrevious().subscribe(onNext: { [weak self] (old, new) in
            guard let self = self, old != new else { return }
            if new == true {
                self.addRow(type: .accountBalance)
            } else {
                self.removeRow(type: .accountBalance)
            }
        }).disposed(by: bag)

        locationsRelay.combinePrevious().subscribe(onNext: { [weak self] (old, new) in
            guard let self = self, old != new else { return }
            if new == true {
                self.addRow(type: .location)
            } else {
                self.removeRow(type: .location)
            }
        }).disposed(by: bag)

        customerServiceRelay.combinePrevious().subscribe(onNext: { [weak self] (old, new) in
            guard let self = self, old != new else { return }
            if new?.isEmpty == true {
                self.removeRow(type: .customerService)
            } else {
                self.addRow(type: .customerService)
            }
        }).disposed(by: bag)
    }

    private func addRow(type: RowType) {
        guard !menuRows.contains(type) else { return }
        menuRows.append(type)
        menuRows.sort { $0.rawValue < $1.rawValue }

        let index = menuRows.firstIndex(of: type)!
        menuTable.insertRows(at: [index], withRowType: type.identifier)
        updateRowsWithLocalization([index])
    }

    private func removeRow(type: RowType) {
        guard let index = menuRows.firstIndex(of: type) else { return }
        menuRows.remove(at: index)
        menuTable.removeRows(at: [index])
    }

    @objc private func watchAppDidBecomeActive(_ sender: Notification) {
        // Refresh the menu in case company attributes changed
        getCompanyAttributes()
    }
    
    @objc private func loadComponents(_ sender: Notification) {
        setupL10ns()
    }

    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch segueIdentifier {
        case "accountsSegue":
            return [ "segue" : "hierarchical", "data" : "" ]

        case "locationsSegue":
            return [ "segue" : "hierarchical", "data" : "" ]

        default:
            return [ "segue" : "", "data": "" ]
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if menuTable.isEqual(table) && rowIndex == 3 {
            callButtonPressed()
        }
    }

    @IBAction func callButtonPressed() {
        guard let phoneNumber = customerServiceRelay.value else { return }
        guard !phoneNumber.isEmpty else { return }

        if let telURL = URL(string: "tel:\(phoneNumber)") {
            WKExtension.shared().openSystemURL(telURL)
        }
    }

    private func getCompanyAttributes() {
        settingsService.getSettings()
            .subscribe(onSuccess: { [unowned self] companyAttributes in
                self.accountsRelay.accept(companyAttributes.boolValue(forKey: "bankingLogin.snapshot.enabled"))
                self.locationsRelay.accept(companyAttributes.boolValue(forKey: "locations.enabled"))
                let customerServiceNumber: String = companyAttributes.value(forKey: "watch.customer-service.phone-number") ?? ""
                self.customerServiceRelay.accept(customerServiceNumber)
            }, onError: { error in
                log.error("Watch error getting company attributes: \(error)")
            })
            .disposed(by: bag)
    }

    fileprivate func updateRowsWithLocalization(_ rowsIndexes: [Int]) {
        for index in rowsIndexes {
            let menuRow = menuTable.rowController(at: index) as? MenuRowController
            let type = menuRows[index]

            switch type {
            case .accountBalance:
                menuRow?.label.setText(l10nProvider.localize("watch.nav.account-balances.label"))

            case .transaction:
                menuRow?.label.setText(l10nProvider.localize("watch.nav.transactions.label"))

            case .location:
                menuRow?.label.setText(l10nProvider.localize("watch.nav.locations.label"))

            case .customerService:
                menuRow?.label.setText(l10nProvider.localize("watch.nav.customer-service.label"))
            }
        }
    }
    
    private func setupL10ns() {
        l10nProvider = try! DependencyContainer.shared.resolve()
        errorLabel.setText(l10nProvider.localize("watch.error.server-unavailable"))
        for index in 0..<menuRows.count {
            updateRowsWithLocalization([index])
        }
    }
}
