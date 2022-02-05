//
//  StopSinglePaymentViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/9/18.
//

import D3Accounts
import Foundation
import Network
import RxSwift
import UIKit
import UITableViewPresentation

protocol StopSinglePaymentViewControllerDelegate: class {
    func singlePaymentScrollViewDidScroll(_ scrollView: UIScrollView)
    func singlePaymentPresentAlert(_ alert: UIAlertController)
    func singlePaymentHistoryButtonTouched(_ sender: UIButton)
}

final class StopSinglePaymentViewController: UITableViewController {

    private let stoppedPayment: StoppedPayment
    private let account: Account
    private let serviceItem: AccountsService
    private let buttonPresenterFactory: ButtonPresenterFactory
    private let bag = DisposeBag()

    private var dataSource: UITableViewPresentableDataSource!

    // swiftlint:disable:next weak_delegate
    private weak var delegate: StopSinglePaymentViewControllerDelegate?

    private var accountNameHeader: AnyUITableViewHeaderFooterPresentable {
        return .init(CardControlsSectionHeaderPresenter(title: "From: \(account.name)"))
    }
    private var tosHeader: AnyUITableViewHeaderFooterPresentable {
        return .init(CardControlsSectionHeaderPresenter(title: "Example Disclosures"))
    }

    init(stoppedPayment: StoppedPayment,
         account: Account,
         serviceItem: AccountsService,
         delegate: StopSinglePaymentViewControllerDelegate,
         buttonPresenterFactory: ButtonPresenterFactory) {
        self.stoppedPayment = stoppedPayment
        self.account = account
        self.serviceItem = serviceItem
        self.delegate = delegate
        self.buttonPresenterFactory = buttonPresenterFactory
        super.init(nibName: String(describing: type(of: self)), bundle: AccountsPresentationBundle.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)

        // TODO: This (termsOfServiceInfoText) will obviously not be hard coded like this but we need to figure out
        // where this information is going to come from.
        let termsOfServiceInfoText = "This party assumes no responsibility for accuracy, correctness "
            + "or content of the Disclousers provided on this website. You should not assume that the disclusures are continuously "
            + "updated or otherwise contain factual information. The Discllosures provided at this website are provided \"as is\" "
            + "and any warranty (express or implied), condition or other term of any kind including without limitation any warranty"
            + " of merchantability."

        let reviewHistoryButton = buttonPresenterFactory.createButton(buttonTitle: "Review History",
                                                                      style: .buttonOutlineOnSecondary) { [weak self] sender in
            self?.delegate?.singlePaymentHistoryButtonTouched(sender)
        }

        let saveButton = buttonPresenterFactory.createButton(buttonTitle: "Save", style: .buttonPrimary) { [weak self] _ in
            let alertController = UIAlertController(
                title: "",
                message: "Are you sure you want to stop this payment?",
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
            let saveAction = UIAlertAction(
                title: "Continue",
                style: .default,
                handler: { _ in
                    self?.stopPayment()
            })

            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)

            // We are using a delegate pattern here to present this alert
            // because presenting view controllers on detached view controllers
            // is discouraged.
            self?.delegate?.singlePaymentPresentAlert(alertController)
        }

        let tos = [
            AnyUITableViewPresentable(InfoPresenter(info: termsOfServiceInfoText)),
            AnyUITableViewPresentable(reviewHistoryButton),
            AnyUITableViewPresentable(saveButton)
        ]

        let rows = [
            AnyUITableViewPresentable(AmountPresenter(stoppedPayment: stoppedPayment)),
            AnyUITableViewPresentable(CheckNumberPresenter(stoppedPayment: stoppedPayment)),
            AnyUITableViewPresentable(PayeePresenter(stoppedPayment: stoppedPayment))
        ]

        dataSource.tableViewModel = [
            UITableViewSection(rows: rows, header: .presentable(accountNameHeader)),
            UITableViewSection(rows: tos, header: .presentable(tosHeader))
        ]
    }

    private func stopPayment() {
        serviceItem
            .stopSinglePayment(stoppedPayment, forAccountWithId: account.id)
            .subscribe({ event in
                switch event {
                case .success(let stoppedPaymentResponse):
                    print(stoppedPaymentResponse)
                case .error(let error):
                    print(error)
                }
            })
            .disposed(by: bag)
    }
}

extension StopSinglePaymentViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {}

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.singlePaymentScrollViewDidScroll(scrollView)
    }
}
