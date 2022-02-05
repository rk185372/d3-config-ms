//
//  RDCConfirmationViewController.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/28/18.
//

import Analytics
import ComponentKit
import Foundation
import Localization
import Logging
import OpenLinkManager
import RxRelay
import RxSwift
import SnapKit
import Utilities
import Views
import WebKit

final class RDCConfirmationViewController: UIViewControllerComponent, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var depositTitleLabel: UILabelComponent!
    @IBOutlet weak var depositAmountLabel: UILabelComponent!
    @IBOutlet weak var depositDetailLabel: UILabelComponent!
    @IBOutlet weak var topDividerView: RDCDividerView!
    @IBOutlet weak var topDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleDividerView: RDCDividerView!
    @IBOutlet weak var middleDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var disclosureWebView: WKWebView!
    @IBOutlet weak var bottomDividerView: RDCDividerView!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButtonComponent!
    
    private let rdcService: RDCService
    private let rdcSuccessViewControllerFactory: RDCSuccessViewControllerFactory
    private let rdcDepositErrorViewControllerFactory: RDCDepositErrorViewControllerFactory
    private let displayMessages: [String]
    private let tableViewStyle: TableViewStyle
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager

    private var request: RDCRequest
    
    weak var delegate: RDCDepositFlowDelegate?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcRequest: RDCRequest,
         rdcService: RDCService,
         rdcSuccessViewControllerFactory: RDCSuccessViewControllerFactory,
         rdcDepositErrorViewControllerFactory: RDCDepositErrorViewControllerFactory,
         displayMessages: [String],
         pdfPresenter: PDFPresenter,
         openLinkManager: OpenLinkManager,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory) {
        self.request = rdcRequest
        self.rdcService = rdcService
        self.rdcSuccessViewControllerFactory = rdcSuccessViewControllerFactory
        self.rdcDepositErrorViewControllerFactory = rdcDepositErrorViewControllerFactory
        self.displayMessages = displayMessages
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager
        
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
        
        configureView()
        
        let viewStyle: ViewStyle = componentStyleProvider![(view as! UIViewComponent).style!]
        let textStyle: LabelStyle = componentStyleProvider![LabelStyleKey(size: .h2, color: .onDefault).keyValue]
        
        let message = displayMessages.reduce("") { $0 + $1 + "<br>" }

        if case let ComponentBackground.solid(color: color) = viewStyle.background {
            let other = "<style>body { background: \(color.hexString()); color: \(textStyle.textColor.hexString()) }</style>" + message
            disclosureWebView.loadHTMLString(HTMLMobileFormatter.format(other), baseURL: nil)
        } else {
            disclosureWebView.loadHTMLString(HTMLMobileFormatter.format(message), baseURL: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
    
    func configureView() {

        [
            topDividerView,
            middleDividerView,
            bottomDividerView
        ].forEach {
            $0.backgroundColor = self.tableViewStyle.separatorColor.color
        }
        
        [
            topDividerViewHeightConstraint,
            middleDividerViewHeightConstraint,
            bottomDividerViewHeightConstraint
        ].forEach {
            $0?.setConstantToPixelWidth()
        }
        
        navigationStyleItem.hideShadowImage()
        
        guard let amountString = NumberFormatter.currencyFormatter(currencyCode: request.account.currencyCode)
            .string(from: (request.amount as NSDecimalNumber)) else {
                return
        }
        
        depositAmountLabel.text = amountString
        depositDetailLabel.text = l10nProvider
            .localize("dashboard.widget.deposit.confirm.string", parameterMap: [
                "amount": amountString,
                "account": request.account.displayableName
            ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "CloseButton"),
            style: .plain,
            target: nil,
            action: nil
        )

        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "rdc-confirmation-close-button"

        navigationItem
            .rightBarButtonItem?
            .rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.closeView()
            })
            .disposed(by: bag)

        disclosureWebView.navigationDelegate = self
        disclosureWebView.uiDelegate = self
    }
    
    @IBAction func sendRequest(_ sender: UIButtonComponent) {
        cancelables.cancel()
        
        sender.isLoading = true
        sender.isEnabled = false
        
        cancelables.insert {
            sender.isLoading = false
            sender.isEnabled = true
        }
        
        request.localDateTime = ISO8601DateFormatter().string(from: Date())
        
        rdcService.depositCheck(request)
            .subscribe { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    // Note: The `retakeRequired` was not implemented in 3.X and therefor isn't here
                    // but it is case that should be done at some point.
                    if response.confirmationRequired ?? false {
                        self.depositTitleLabel.text = self.l10nProvider.localize("dashboard.widget.deposit.confirm.title")
                        self.submitButton.setTitle(self.l10nProvider.localize("dashboard.widget.deposit.btn.continue"), for: .normal)
                        self.request.finalizeOnly = true
                        self.request.frontImage = nil
                        self.request.backImage = nil
                    } else if response.success ?? false {
                        let successVC = self.rdcSuccessViewControllerFactory.create(request: self.request, response: response)
                        successVC.delegate = self.delegate
                        self.navigationController?.pushViewController(successVC, animated: true)
                    } else {
                        let errorVC = self.rdcDepositErrorViewControllerFactory.create(responseError: response)
                        errorVC.delegate = self.delegate
                        self.navigationController?.pushViewController(errorVC, animated: true)
                    }

                    self.cancelables.cancel()
                case .error:
                    //Handle Failure
                    let alert = UIAlertController(
                        title: self.l10nProvider.localize("dashboard.widget.deposit.error.title"),
                        message: self.l10nProvider.localize("dashboard.widget.deposit.unsuccessful.title"),
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(
                            title: self.l10nProvider.localize("app.alert.btn.ok"),
                            style: .default,
                            handler: nil
                        )
                    )
                    self.present(alert, animated: true, completion: nil)
                    self.cancelables.cancel()
                }
        }
        .disposed(by: cancelables)
    }
    
    func closeView() {
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
    }

    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let url = navigationResponse.response.url else { return }

        let shouldOpenWebView = openLinkManager.openWebViewNavigationDelegate(
            decidePolicyFor: navigationResponse,
            decisionHandler: decisionHandler,
            pdfPresenter: pdfPresenter,
            viewController: self,
            bag: bag
        )

        if shouldOpenWebView {
            let viewController = externalWebViewControllerFactory.create(destination: .url(url))

            self.present(viewController, animated: true, completion: nil)
        }

    }

    // MARK: WKUIDelegate
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        guard navigationAction.targetFrame == nil else { return nil }
        guard let url = navigationAction.request.url else { return nil }

        let shouldOpenWebView = openLinkManager.openWebViewUIDelegate(
            createWebViewWith: configuration,
            for: navigationAction,
            windowFeatures: windowFeatures,
            pdfPresenter: pdfPresenter,
            viewController: self,
            bag: bag
        )

        if shouldOpenWebView {
            let viewController = externalWebViewControllerFactory.create(destination: .url(url))

            self.present(viewController, animated: true, completion: nil)
        }

        return nil
    }
}

extension RDCConfirmationViewController: TrackableScreen {
    var screenName: String {
        return "RDC Confirm Screen"
    }
}
