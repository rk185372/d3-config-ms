//
//  WelcomeViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/10/19.
//

import UIKit
import ComponentKit
import Localization
import WebKit

final class WelcomeViewController: UIViewControllerComponent, ContentViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var delegate: ContentViewDelegate?
    private let url: URL
    
    public init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider, url: URL) {
        self.url = url
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "WelcomeViewController",
            bundle: FeatureTourBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        webView.load(URLRequest(url: url))
    }

    @IBAction func goToNextPressed(_ sender: UIButton) {
        delegate?.proceedToNextScreen()
    }
    
    @IBAction func goToLoginPressed(_ sender: UIButton) {
        delegate?.proceedToLogin()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.startAnimation()", completionHandler: nil)
    }
}
