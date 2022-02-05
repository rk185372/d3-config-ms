//
//  WebContentViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import UIKit
import ComponentKit
import Localization
import WebKit
import RxSwift
import RxCocoa

final class WebContentViewController: UIViewControllerComponent, WKNavigationDelegate, ContentViewController {
    
    weak var delegate: ContentViewDelegate?

    @IBOutlet weak var webView: WKWebView!
    
    private let url: URL
    
    private let appearRelay: PublishRelay<Void> = PublishRelay()
    private let webFinishedLoadingRelay: PublishRelay<Void> = PublishRelay()
    
    init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider, url: URL) {
        self.url = url
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "WebContentViewController",
            bundle: FeatureTourBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        webView.load(URLRequest(url: url))
        
        Observable
            .combineLatest(appearRelay.asObservable(), webFinishedLoadingRelay.asObservable())
            .take(1)
            .subscribe(onNext: { [unowned self] _ in
                self.webView.evaluateJavaScript("window.startAnimation()", completionHandler: nil)
            })
            .disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearRelay.accept(())
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webFinishedLoadingRelay.accept(())
    }
}
