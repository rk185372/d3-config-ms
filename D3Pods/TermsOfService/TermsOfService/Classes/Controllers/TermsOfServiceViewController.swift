//
//  TermsOfServiceViewController.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/4/18.
//

import Analytics
import AppConfiguration
import AuthGenericViewController
import ComponentKit
import Localization
import Logging
import OpenLinkManager
import PostAuthFlowController
import SimpleMarkdownParser
import SnapKit
import UIKit
import Utilities
import Views
import WebKit

final class TermsOfServiceViewController: AuthGenericViewController, WKNavigationDelegate, WKUIDelegate {
    
    private let termsOfService: TermsOfService
    private let termsOfServiceService: TermsOfServiceService
    private let pdfPresenter: PDFPresenter
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let openLinkManager: OpenLinkManager
    private let restServer: RestServer
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rejectButton: UIButtonComponent!
    @IBOutlet weak var acceptButton: UIButtonComponent!
    
    @IBOutlet weak var tosChecksTitleLabel: UILabelComponent!
    private var tosCheckboxs: [TOSCheckboxView] = []
    private var kvos: [NSKeyValueObservation] = []
    
    weak var controller: PostAuthFlowController?
    
    private lazy var loadingView = {
        return LoadingView(
            activityIndicatorColor: .white,
            backgroundColor: UIColor.black.withAlphaComponent(0.4)
        )
    }()
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         termsOfService: TermsOfService,
         service: TermsOfServiceService,
         postAuthFlowController: PostAuthFlowController?,
         pdfPresenter: PDFPresenter,
         openLinkManager: OpenLinkManager,
         externalWebViewControllerFactory: ExternalWebViewControllerFactory,
         restServer: RestServer) {
        self.termsOfService = termsOfService
        self.termsOfServiceService = service
        self.controller = postAuthFlowController
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.openLinkManager = openLinkManager
        self.restServer = restServer
        super.init(l10nProvider: l10nProvider, componentStyleProvider: componentStyleProvider)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tosView = TermsOfServiceBundle.bundle.loadNibNamed("TermsOfServiceView", owner: self, options: nil)?.first as! UIView
        containerView.addSubview(tosView)
        tosView.snp.makeConstraints { make in
            make
                .edges
                .equalTo(containerView)
        }
        
        let checkboxesTitle = l10nProvider.localize("enrollment.tos.accept.body")
        if checkboxesTitle != "enrollment.tos.accept.body", !checkboxesTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            tosChecksTitleLabel.attributedText = SimpleMarkdownConverter.toAttributedString(defaultFont: tosChecksTitleLabel.font,
                                                                                            markdownText: checkboxesTitle)
            buttonsStackView.addArrangedSubview(tosChecksTitleLabel)
        }
            
        for i in 1...3 {
            let prefix = "enrollment.tos.accept.check.\(i)", labelKey = "\(prefix).label"
            let checkboxText = l10nProvider.localize(labelKey)
            if checkboxText != labelKey, !checkboxText.trimmingCharacters(in: .whitespaces).isEmpty {
                let checkView = TOSCheckboxView(title: l10nProvider.localize("\(prefix).text"),
                                                checkboxText: checkboxText,
                                                checkboxErrorText: l10nProvider.localize("\(prefix).error"))
                tosCheckboxs.append(checkView)
                buttonsStackView.addArrangedSubview(checkView)
            }
        }
        
        buttonsStackView.addArrangedSubview(rejectButton)
        buttonsStackView.addArrangedSubview(acceptButton)

        setTermsOfServiceText(termsOfService.text)

        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        kvos.append(webView.scrollView.observe(\.contentSize, options: .new) { [weak self] scrollView, _ in
            self?.webViewHeight.constant = scrollView.contentSize.height
        })
        
        allowContentScrolling = true
    }
    
    private func setTermsOfServiceText(_ text: String) {
        webView.loadHTMLString(HTMLMobileFormatter.format(text), baseURL: nil)
    }
    
    private func beginLoading(fromButton button: UIButtonComponent) {
        cancelables.cancel()
        
        let controls: [UIControl] = [rejectButton, acceptButton]
        
        button.isLoading = true
        controls.forEach { $0.isEnabled = false }
        
        cancelables.insert {
            button.isLoading = false
            controls.forEach { $0.isEnabled = true }
        }
    }
    
    public func showLoadingView() {
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.spinner.isHidden = false
        loadingView.spinner.startAnimating()
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    public func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    
    @IBAction func rejectButtonPressed(sender: UIButtonComponent) {
        cancelables.cancel()
        
        self.controller?.cancel()
    }
    
    @IBAction func acceptButtonPressed(sender: UIButtonComponent) {
        
        tosCheckboxs.forEach {
            $0.showError(!$0.isChecked)
        }
        guard tosCheckboxs.filter({ !$0.isChecked }).isEmpty else {
            return
        }
    
        beginLoading(fromButton: sender)
        
        termsOfServiceService.accept(termsOfService: termsOfService)
            .subscribe({ [unowned self] (result) in
                switch result {
                case .success:
                    self.controller?.advance()
                case .error(let error):
                    log.error("Error accepting terms of service \(error)", context: error)
                    self.showErrorAlert()
                    self.cancelables.cancel()
                }
            })
            .disposed(by: cancelables)
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

    @IBAction func downloadPressed() {
        guard let pdfURL = URL(string: "\(restServer.url)v4/content/legal/\(termsOfService.service)/tos.pdf") else {
            return
        }
        showLoadingView()
        pdfPresenter.presentPDF(atURL: pdfURL, fromViewController: self).subscribe(onCompleted: {
            self.hideLoadingView()
        }, onError: { error in
            log.error("Error presenting PDF: \(error)", context: error)
            self.hideLoadingView()
        }) .disposed(by: bag)
    }
    
    @IBAction func printPressed() {
        downloadPressed()
    }
}

extension TermsOfServiceViewController: TrackableScreen {
    var screenName: String {
        return "LoginFlow/Tos"
    }
}
