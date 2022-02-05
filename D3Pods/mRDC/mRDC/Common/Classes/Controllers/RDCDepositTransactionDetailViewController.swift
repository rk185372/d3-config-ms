//
//  RDCDepositTransactionDetailViewController.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/3/18.
//

import Foundation
import Localization
import Logging
import ComponentKit
import Utilities
import Views

final class RDCDepositTransactionDetailViewController: UIViewControllerComponent {
    
    @IBOutlet weak var frontImageView: UIImageViewComponent!
    @IBOutlet weak var frontImageLabel: UILabelComponent!
    
    @IBOutlet weak var backImageView: UIImageViewComponent!
    @IBOutlet weak var backImageLabel: UILabelComponent!
    
    @IBOutlet weak var statusTitleLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!
    @IBOutlet weak var dateTitleLabel: UILabelComponent!
    @IBOutlet weak var dateLabel: UILabelComponent!
    @IBOutlet weak var submittedAmountTitleLabel: UILabelComponent!
    @IBOutlet weak var submittedAmountLabel: UILabelComponent!
    @IBOutlet weak var adjustedAmountTitleLabel: UILabelComponent!
    @IBOutlet weak var adjustedAmountLabel: UILabelComponent!
    @IBOutlet weak var currentAmountTitleLabel: UILabelComponent!
    @IBOutlet weak var currentAmountLabel: UILabelComponent!
    @IBOutlet weak var confirmationNumberTitlleLabel: UILabelComponent!
    @IBOutlet weak var confirmationNumberLabel: UILabelComponent!

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var imagesHorizontalStackView: UIStackView!
    @IBOutlet weak var topTextStackView: UIStackView!
    @IBOutlet weak var adjustedAmountStackView: UIStackView!
    @IBOutlet weak var postedAmountStackView: UIStackView!
    @IBOutlet weak var confirmationNumberStackView: UIStackView!

    let frontSpinner = LoadingView()
    let backSpinner = LoadingView()
    
    private let rdcService: RDCService
    private let device: Device
    private let depositTransaction: DepositTransaction
    private var imageData: [RDCImageData]?
    private let rdcDepositImagesViewControllerFactory: RDCDepositImagesViewControllerFactory
    
    private let kFrontImageViewTag = 0
    private let kBackImageViewTag = 1
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcService: RDCService,
         device: Device,
         rdcDepositImagesViewControllerFactory: RDCDepositImagesViewControllerFactory,
         depositTransaction: DepositTransaction) {
        self.rdcService = rdcService
        self.device = device
        self.rdcDepositImagesViewControllerFactory = rdcDepositImagesViewControllerFactory
        self.depositTransaction = depositTransaction
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        showSpinners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchImages()
    }
    
    func getStatusText(status: String) -> String {
        switch(status) {
        case "SUBMITTED":
            return "\(status), \(l10nProvider.localize("dashboard.widget.deposit.detail.statusMessage"))"
        default:
            return status
        }
    }
    
    private func setupViews() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        let currencyFormatter = NumberFormatter.currencyFormatter()

        statusTitleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.status")):"
        statusLabel.text = getStatusText(status: depositTransaction.status)

        dateTitleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.transactiondate")):"
        dateLabel.text = depositTransaction.dateAndTimeString()

        if let postedAmount = depositTransaction.postedAmount {
            submittedAmountTitleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.submittedamount")):"
            submittedAmountLabel.text = currencyFormatter.string(from: postedAmount)
            postedAmountStackView.isHidden = false
        } else {
            submittedAmountTitleLabel.text = nil
            submittedAmountLabel.text = nil
            postedAmountStackView.isHidden = true
        }

        if let adjustedAmount = depositTransaction.adjustedAmount {
            adjustedAmountTitleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.adjustedamount")):"
            adjustedAmountLabel.text = currencyFormatter.string(from: adjustedAmount)
            adjustedAmountStackView.isHidden = false
        } else {
            adjustedAmountTitleLabel.text = nil
            adjustedAmountLabel.text = nil
            adjustedAmountStackView.isHidden = true
        }

        currentAmountTitleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.currentamount")):"
        currentAmountLabel.text = currencyFormatter.string(from: depositTransaction.currentAmount)

        if let confirmationNumber = depositTransaction.confirmationNumber, !confirmationNumber.isEmpty {
            confirmationNumberTitlleLabel.text = "\(l10nProvider.localize("dashboard.widget.deposit.detail.confirmation")):"
            confirmationNumberLabel.text = confirmationNumber
            confirmationNumberStackView.isHidden = false
        } else {
            confirmationNumberTitlleLabel.text = nil
            confirmationNumberLabel.text = nil
            confirmationNumberStackView.isHidden = true
        }

        mainStackView.setCustomSpacing(25, after: imagesHorizontalStackView)
        
        let frontTap = UITapGestureRecognizer(target: self, action: #selector(showImagesViewController(_:)))
        frontImageView.addGestureRecognizer(frontTap)
        frontImageView.tag = kFrontImageViewTag
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(showImagesViewController(_:)))
        backImageView.addGestureRecognizer(backTap)
        backImageView.tag = kBackImageViewTag
    }
    
    private func fetchImages() {
        
        guard imageData == nil else {
            return
        }
        
        showSpinners()

        rdcService
            .getDepositTransactionImages(transaction: depositTransaction, withUuid: device.uuid)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                self.hideSpinners()
                
                switch event {
                case .success(let response):
                    let frontImageData = response.first(where: {$0.itemImageAngle == .front })
                    self.frontImageView.image = frontImageData?.image()
                    
                    let backImageData = response.first(where: {$0.itemImageAngle == .back })
                    self.backImageView.image = backImageData?.image()
                    
                    self.imageData = response
                case .error:
                    log.error("Failed to fetch transaction images")
                }
            })
            .disposed(by: bag)
    }
    
    @objc private func showImagesViewController(_ gesture: UIGestureRecognizer) {
        guard let imageData = imageData else {
            return
        }
        
        guard let view = gesture.view else {
            return
        }
        
        var backCheckPressed = false
        if view.tag == kBackImageViewTag {
            backCheckPressed = true
        }
        
        let imageVC = rdcDepositImagesViewControllerFactory.create(imageData: imageData, backCheckPressed: backCheckPressed)
        navigationController?.pushViewController(imageVC, animated: true)
    }
    
    private func showSpinners() {
        frontImageView.addSubview(frontSpinner)
        frontSpinner.makeMatch(view: frontImageView)
        
        backImageView.addSubview(backSpinner)
        backSpinner.makeMatch(view: backImageView)
    }
    
    private func hideSpinners() {
        frontSpinner.removeFromSuperview()
        backSpinner.removeFromSuperview()
    }
}
