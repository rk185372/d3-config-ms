//
//  RDCSuccessViewController.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/29/18.
//

import Foundation
import ComponentKit
import Localization
import RxSwift
import RxRelay
import Analytics

final class RDCSuccessViewController: UIViewControllerComponent {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabelComponent!
    @IBOutlet weak var dividerView: RDCDividerView!
    @IBOutlet weak var dividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomDividerView: RDCDividerView!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!
    
    private let request: RDCRequest
    private let response: RDCResponse
    
    private let tableViewStyle: TableViewStyle
    
    weak var delegate: RDCDepositFlowDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         request: RDCRequest,
         response: RDCResponse) {
        self.request = request
        self.response = response

        tableViewStyle = componentStyleProvider[TableViewStyleKey.tableViewOnDefault]
        
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
        
        dividerView.backgroundColor = tableViewStyle.separatorColor.color
        bottomDividerView.backgroundColor = tableViewStyle.separatorColor.color
        dividerViewHeightConstraint.setConstantToPixelWidth()
        bottomDividerViewHeightConstraint.setConstantToPixelWidth()
        
        navigationItem.hidesBackButton = true
        
        guard let amountString = NumberFormatter
            .currencyFormatter(currencyCode: request.account.currencyCode)
            .string(from: (request.amount as NSDecimalNumber)) else { return }
        
        descriptionLabel.text = l10nProvider
            .localize("dashboard.widget.deposit.success.text", parameterMap: [
                "amount": amountString,
                "account": request.account.displayableName
            ])

        if let confirmationNumber = response.confirmation {
            let map: [String: Any] = ["confirmationNumber": confirmationNumber]
            confirmationLabel.text = l10nProvider.localize("dashboard.widget.deposit.success.confirmationNumber", parameterMap: map)
            confirmationLabel.isHidden = false
        } else {
            confirmationLabel.text = nil
            confirmationLabel.isHidden = true
        }
    }
    
    @IBAction func allDone() {
        NotificationCenter.default.post(name: .depositSuccessful, object: nil)
        
        delegate?.depositFlowDidFinish(success: true)
    }
}

extension RDCSuccessViewController: TrackableScreen {
    var screenName: String {
        return "RDC Result"
    }
}
