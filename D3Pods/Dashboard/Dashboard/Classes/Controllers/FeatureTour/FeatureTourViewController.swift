//
//  FeatureTourViewController.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 15/10/2021.
//

import UIKit
import ComponentKit
import Localization
import WebKit
import RxSwift

public protocol FeatureTourViewControllerDelegate: AnyObject {
    func tourDismissed()
    func didTapLearnMore()
    func didCompleteTour()
    func tourURL() -> URL?
}

final class FeatureTourViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var startTourButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private let l10nProvider: L10nProvider
    private weak var delegate: FeatureTourViewControllerDelegate?
    private let bag = DisposeBag()
    
    init(l10nProvider: L10nProvider, delegate: FeatureTourViewControllerDelegate) {
        self.l10nProvider = l10nProvider
        self.delegate = delegate
        super.init(nibName: "FeatureTourViewController", bundle: DashboardBundle.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = l10nProvider.localize("tour.banking-experience.what-is-new")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: l10nProvider.localize("tour.banking-experience.btn.close"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        
        startTourButton.rx.tap.bind {
            self.startTour()
        }
        .disposed(by: bag)
        
        webView.isHidden = true
        spinner.isHidden = true
        webView.navigationDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.tourDismissed()
    }
    
    @objc private func close() {
        dismiss()
    }
    
    private func startTour() {
        guard let tourURL = delegate?.tourURL() else {
            return
        }
        showSpinner()
        webView.isHidden = false
        webView.load(URLRequest(url: tourURL))
    }
    
    private func showSpinner() {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    private func dismiss() {
        dismiss(animated: true)
    }
}

extension FeatureTourViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.url?.pathComponents.contains("d3:tourCompleted") == true {
            self.delegate?.didCompleteTour()
            dismiss()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
}
