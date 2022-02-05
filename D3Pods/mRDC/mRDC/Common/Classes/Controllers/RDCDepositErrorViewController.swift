//
//  RDCDepositErrorViewController.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/15/18.
//

import Foundation
import ComponentKit
import Localization
import RxSwift
import RxRelay
import Analytics

final class RDCDepositErrorViewController: UIViewControllerComponent {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dividerView: RDCDividerView!
    @IBOutlet weak var dividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomDividerView: RDCDividerView!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!
    
    private let responseError: RDCResponse
    
    private let tableViewStyle: TableViewStyle
    
    weak var delegate: RDCDepositFlowDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         responseError: RDCResponse) {
        self.responseError = responseError
        
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
        navigationItem.hidesBackButton = true
        navigationStyleItem.hideShadowImage()
        
        dividerView.backgroundColor = tableViewStyle.separatorColor.color
        bottomDividerView.backgroundColor = tableViewStyle.separatorColor.color
        dividerViewHeightConstraint.setConstantToPixelWidth()
        bottomDividerViewHeightConstraint.setConstantToPixelWidth()
        
        buildErrorString()
    }
    
    fileprivate func buildErrorString() {
        var errorString = ""
        
        if let errorDescription = responseError.errorDescription {
            errorString += errorDescription
        } else {
            errorString += l10nProvider.localize("dashboard.widget.deposit.unsuccessful.title")
        }
        
        if let errorMessages = responseError.errorMessages {
            errorString += "\n\n"
            errorMessages.forEach { errorString += $0 }
        } else if let message = responseError.message {
            errorString += "\n\n"
            errorString += message
        }
        
        descriptionLabel.text = errorString
    }
    
    @IBAction func cancelDeposit() {
        delegate?.depositFlowDidFinish(success: false)
    }
    
    @IBAction func tryAgainDeposit() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension RDCDepositErrorViewController: TrackableScreen {
    var screenName: String {
        return "RDC Result"
    }
}
