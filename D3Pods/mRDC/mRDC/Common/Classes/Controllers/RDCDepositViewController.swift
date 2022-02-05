//
//  RemoteDepositViewController.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import InAppRatingApi
import UIKit
import UITableViewPresentation
import Utilities
import Analytics
import ComponentKit
import Localization
import Session
import AccountsPresentation
import Views
import SnapKit
import RxSwift
import RxRelay

final class RDCDepositViewController: UIViewControllerComponent {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomDividerView: UIView!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButtonComponent!
    
    private let device: Device
    private let rdcConfirmationViewControllerFactory: RDCConfirmationViewControllerFactory
    private let depositViewModel: RDCDepositViewModel
    private let inAppRatingManager: InAppRatingManager
    
    private let tableViewStyle: TableViewStyle
    
    weak var delegate: RDCDepositFlowDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         device: Device,
         rdcConfirmationViewControllerFactory: RDCConfirmationViewControllerFactory,
         rdcDepositViewModel: RDCDepositViewModel,
         inAppRatingManager: InAppRatingManager) {
        self.device = device
        self.rdcConfirmationViewControllerFactory = rdcConfirmationViewControllerFactory
        self.depositViewModel = rdcDepositViewModel
        self.inAppRatingManager = inAppRatingManager

        tableViewStyle = componentStyleProvider[TableViewStyleKey.tableViewOnPrimary]
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationStyleItem.hideShadowImage()
        
        bottomDividerView.backgroundColor = tableViewStyle.separatorColor.color
        bottomDividerViewHeightConstraint.setConstantToPixelWidth()
        
        depositViewModel.configureDataSource(tableView: tableView)
        depositViewModel.depositViewDelegate = self
        depositViewModel.getAccounts()
        
        depositViewModel
            .canSubmitDeposit
            .drive(submitButton.rx.isEnabled)
            .disposed(by: bag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "CloseButton"),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "rdc-deposit-controller-close-button"
        navigationItem.rightBarButtonItem?.accessibilityLabel = l10nProvider.localize("device.rdc.close.btn.altText")
        navigationItem
            .rightBarButtonItem?
            .rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.closeView()
            })
            .disposed(by: bag)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem
            .backBarButtonItem?
            .rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    @IBAction func submit() {
        
        guard let account = depositViewModel.selectedAccount,
            let amount = depositViewModel.depositAmount,
            let images = depositViewModel.checkImages,
            let listResponse = depositViewModel.listResponse else {
                return
        }
        
        guard amount > 0 && amount < 1000000000 else {
            showDepositRangeNotification()
            return
        }
        
        let request = RDCRequest(
            deviceUuid: device.uuid,
            account: account,
            amount: amount,
            frontImage: images.encodedFrontImage,
            backImage: images.encodedBackImage,
            finalizeOnly: false,
            sessionId: listResponse.sessionId,
            accountKeys: listResponse.accountKeys,
            localDateTime: ISO8601DateFormatter().string(from: Date())
        )
        
        let confirmationVC = rdcConfirmationViewControllerFactory.create(request: request, displayMessages: listResponse.displayMessages)
        confirmationVC.delegate = delegate
        self.navigationController?.pushViewController(confirmationVC, animated: true)
    }
    
    func showDepositRangeNotification() {
        let alert = UIAlertController(
            title: nil,
            message: l10nProvider.localize("deposit.validate.amount.range"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: l10nProvider.localize("app.alert.btn.ok"),
                style: .default,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    func closeView() {
        if depositViewModel.isDirty {
            let alert = UIAlertController(
                title: l10nProvider.localize("dashboard.widget.deposit.flow-cancel.title"),
                message: l10nProvider.localize("dashboard.widget.deposit.flow-cancel.text"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .destructive, handler: { _ in
                self.delegate?.depositFlowDidFinish(success: false)
            }))
            alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.cancel"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            delegate?.depositFlowDidFinish(success: false)
        }
    }
}

extension RDCDepositViewController: RDCDepositViewDelegate {
    func beginLoading() {
        tableView.backgroundView = nil
    }
    
    func failedToLoadAccounts() {
        let noItemsView = NoItemsView()
        noItemsView.makeBlendWithBackground()
        noItemsView.infoLabel.text = l10nProvider.localize("device.rdc.accounts.error")

        noItemsView.tryAgainButton.accessibilityIdentifier = "try-again-deposit-view-controller"
        noItemsView.tryAgainButton.addTarget(
            depositViewModel,
            action: #selector(depositViewModel.getAccounts),
            for: .touchUpInside
        )

        tableView.backgroundView = noItemsView
    }
    
    func noEligibleAccounts() {
        let alertController = UIAlertController(
            title: "",
            message: l10nProvider.localize("deposit.accounts.not.eligible"),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: l10nProvider.localize("app.alert.btn.ok"),
            style: .default,
            handler: { [weak self] _ in
                //Go to the account screen
                self?.tabBarController?.selectedIndex = 0
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentCaptureViewController(_ captureVC: UIViewController) {
        guard let errorVC = captureVC as? RDCCameraRequiredViewController else {
            captureVC.modalPresentationStyle = .fullScreen
            //Capturing the check images should be done in a modal
            self.present(captureVC, animated: true, completion: nil)
            return
        }
        //Errors should be pushed on the navigation stack
        self.navigationController?.pushViewController(errorVC, animated: true)
    }
    
    func presentErrorViewController(_ errorVC: UIViewController) {
        errorVC.title = self.navigationItem.title
        present(errorVC, animated: true, completion: nil)
    }
    
    func dismissCaptureViewController() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }

    func checkImagesCaptured() {
        inAppRatingManager.engage(event: "rdc:checkImages:captured", fromViewController: self)
    }
    
    func doneEditingAmount() {
        UIAccessibility.post(notification: .screenChanged, argument: self.tableView.headerView(forSection: 1))
    }
}

extension RDCDepositViewController: TrackableScreen {
    var screenName: String {
        return "rdcDeposit"
    }
}
