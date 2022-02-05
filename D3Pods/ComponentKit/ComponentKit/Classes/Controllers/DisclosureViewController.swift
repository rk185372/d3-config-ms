//
//  DisclosureViewController.swift
//  Enablement
//
//  Created by Chris Carranza on 8/10/18.
//

import Localization
import Logging
import OpenLinkManager
import RxSwift
import UIKit
import Utilities
import WebKit

public final class DisclosureViewController: UIViewControllerComponent, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var continueButton: UIButtonComponent!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    public weak var delegate: DisclosureViewControllerDelegate?
    
    private let disclosure: Single<String>
    private let errorTitle: String?
    private let errorMessage: String?
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         disclosure: Single<String>,
         errorTitle: String? = nil,
         errorMessage: String? = nil,
         pdfPresenter: PDFPresenter,
         openLinkManager: OpenLinkManager,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory) {
        self.disclosure = disclosure
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: ComponentKitBundle.bundle
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.setImage(UIImage(named: "CloseButton"), for: .normal)
        closeButton.accessibilityLabel = l10nProvider.localize("disclosure.btn.close.altText")

        continueButton.isEnabled = false
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        disclosure.subscribe { [unowned self] (event) in
            switch event {
            case .success(let text):
                self.display(disclosureText: text)
                
            case .error(let error):
                log.error("Error in getting disclosure: \(error)", context: error)
                self.showErrorAlert(title: self.errorTitle, message: self.errorMessage)
            }
        }.disposed(by: bag)

        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    private func display(disclosureText: String) {
        activityIndicatorView.stopAnimating()
        webView.loadHTMLString(formatHTML(disclosureText), baseURL: nil)
        continueButton.isEnabled = true
    }
    
    private func accept() {
        dismiss(animated: true, completion: {
            self.delegate?.disclosureViewController(self, dismissedByAccepting: true)
        })
    }

    private func cancel() {
        dismiss(animated: true, completion: {
            self.delegate?.disclosureViewController(self, dismissedByAccepting: false)
        })
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        cancel()
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        accept()
    }
    
    private func formatHTML(_ html: String) -> String {
        return """
        <html>
        <head>
        <meta name="viewport" content="user-scalable=1.0,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <style>
        body { font-family: -apple-system !important; padding-top: 0px; background: transparent; color: #000000; }
        </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
    }
    
    private func showErrorAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(
            title: title ?? l10nProvider.localize("app.error.generic.title"),
            message: message ?? l10nProvider.localize("app.error.generic"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default) { _ in
                self.cancel()
            }
        )
        
        present(alert, animated: true)
    }

    // MARK: WKNavigationDelegate
    public func webView(_ webView: WKWebView,
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
    public func webView(_ webView: WKWebView,
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

public protocol DisclosureViewControllerDelegate: class {
    func disclosureViewController(_ viewController: DisclosureViewController, dismissedByAccepting accepted: Bool)
}
