//
//  EnableFeatureViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 6/6/18.
//
//

import UIKit
import WebKit
import Localization
import Logging
import ComponentKit
import AuthGenericViewController
import SnapKit
import RxSwift
import PostAuthFlowController
import Utilities
import Analytics

final class EnableFeatureViewController: AuthGenericViewController {

    private let configuration: EnableFeatureConfiguration
    private let enableFeatureDisclosureViewControllerFactory: DisclosureViewControllerFactory
    
    @IBOutlet weak var helperText: UILabelComponent!
    @IBOutlet weak var enableButton: UIButtonComponent!
    @IBOutlet weak var disableButton: UIButtonComponent!
    @IBOutlet weak var viewDisclosuresButton: UIButtonComponent!
    
    @IBOutlet weak var backgroundCenterIconView: CenterIconView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var postAuthFlowController: PostAuthFlowController?
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         configuration: EnableFeatureConfiguration,
         enableFeatureDisclosureViewControllerFactory: DisclosureViewControllerFactory,
         postAuthFlowController: PostAuthFlowController?) {
        self.configuration = configuration
        self.enableFeatureDisclosureViewControllerFactory = enableFeatureDisclosureViewControllerFactory
        self.postAuthFlowController = postAuthFlowController
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let enableFeatureView = EnablementBundle.bundle.loadNibNamed("EnableFeatureView", owner: self, options: nil)?.first as! UIStackView
        containerView.addSubview(enableFeatureView)
        enableFeatureView.snp.makeConstraints { make in
            make
                .edges
                .equalTo(containerView)
                .inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
        
        buttonsStackView.addArrangedSubview(disableButton)
        buttonsStackView.addArrangedSubview(enableButton)

        imageView.image = configuration.image
        helperText.text = configuration.helperText
        disableButton.setTitle(configuration.disableButtonTitle, for: .normal)
        enableButton.setTitle(configuration.enableButtonTitle, for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundCenterIconView.layer.cornerRadius = backgroundCenterIconView.frame.height / 2
    }
    
    private func showEnablementErrorAlert() {
        let alert = UIAlertController(
            title: self.configuration.enableErrorAlertTitle,
            message: self.configuration.enableErrorAlertMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: l10nProvider.localize("app.alert.btn.ok"), style: .default, handler: { _ in
            self.proceedToNextStep()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func viewDisclosureButtonPressed(_ sender: UIButton) {
        cancelables.cancel()
        
        let disclosure = configuration.retrieveDisclosureText()
        let disclosureViewController = self.enableFeatureDisclosureViewControllerFactory.create(disclosure: disclosure)
        
        disclosureViewController.delegate = self
        disclosureViewController.modalPresentationStyle = .custom
        disclosureViewController.transitioningDelegate = self
        
        self.present(disclosureViewController, animated: true)
    }
    
    @IBAction func enableButtonSelected(_ sender: UIButtonComponent) {
        cancelables.cancel()
        
        sender.isLoading = true
        sender.isEnabled = false
        
        cancelables.insert {
            sender.isLoading = false
            sender.isEnabled = true
        }
        
        configuration.enable()
            .subscribe { [unowned self] event in
                switch event {
                case .completed:
                    self.proceedToNextStep()
                case .error(let error):
                    log.error(
                        "Error enabling feature: \(error)",
                        context: error
                    )
                    self.showEnablementErrorAlert()
                    self.cancelables.cancel()
                }
            }
            .disposed(by: cancelables)
    }

    @IBAction func disableButtonSelected() {
        cancelables.cancel()
        
        proceedToNextStep()
    }
    
    func proceedToNextStep() {
        configuration.completionHandler()
        postAuthFlowController?.advance()
    }
}

extension EnableFeatureViewController: TrackableScreen {
    var screenName: String {
        return "LoginFlow/Enablement"
    }
}

extension EnableFeatureViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DisclosurePresentationController(
            presentedViewController: presented,
            presenting: presenting,
            topInset: headerView.frame.height
        )
    }
}

extension EnableFeatureViewController: DisclosureViewControllerDelegate {
    func disclosureViewController(_ viewController: DisclosureViewController, dismissedByAccepting accepted: Bool) {
        if accepted {
            enableButtonSelected(enableButton)
        }
    }
}
