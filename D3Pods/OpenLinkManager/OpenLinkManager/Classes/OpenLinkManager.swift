//
//  OpenLinkManager.swift
//  OpenLinkManager
//
//  Created by Richard Crichlow on 11/20/19.
//

import Foundation
import Logging
import RxRelay
import RxSwift
import Utilities
import WebKit

public class OpenLinkManager {
    public init() { }

    public func openWebViewNavigationDelegate(decidePolicyFor navigationResponse: WKNavigationResponse,
                                              decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void,
                                              pdfPresenter: PDFPresenter,
                                              viewController: UIViewController,
                                              bag: DisposeBag) -> Bool {
        // If we are here, it means that the webView has navigated to a new url.
        // Rather than navigating inside of the webView where there are no navigation
        // buttons. We will open either an ExternalWebViewController (non pdf's) or the PDF Presenter.
        // This situation occurs when the navigation is not trying to open a new web view.
        defer { decisionHandler(.cancel) }

        guard let url = navigationResponse.response.url else { return false }

        if navigationResponse.response.mimeType == "application/pdf" {
            pdfPresenter
                .presentPDF(atURL: url, fromViewController: viewController)
                .subscribe({ (error) in
                    log.error("Error Presenting PDF at url: \(url)")
                })
                .disposed(by: bag)

            return false
        } else {
            return true
        }
    }

    public func openWebViewUIDelegate(createWebViewWith configuration: WKWebViewConfiguration,
                                      for navigationAction: WKNavigationAction,
                                      windowFeatures: WKWindowFeatures,
                                      pdfPresenter: PDFPresenter,
                                      viewController: UIViewController,
                                      bag: DisposeBag) -> Bool {
        // If we are here it means that the webView is trying to open a new window
        // for a link that was touched inside of the webView (e.g. a link in the disclosure agreement). The webView
        // does not open new windows so, instead, we catch the request return nil as the new
        // WKWebView and take our own action to present a pdf or open an ExternalWebViewController.

        guard let url = navigationAction.request.url else { return false }

        if url.pathExtension == "pdf" {
            pdfPresenter
                .presentPDF(atURL: url, fromViewController: viewController)
                .subscribe({ (error) in
                    log.error("Error Presenting PDF at url: \(url)")
                })
                .disposed(by: bag)

            return false
        } else {
            return true
        }
    }
}
