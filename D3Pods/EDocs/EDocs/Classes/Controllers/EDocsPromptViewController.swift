//
//  EDocsPromptViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/4/17.
//

import Foundation
import UIKit
import PodHelper
import ComponentKit
import RxSwift
import Utilities
import Analytics

final class EDocsPromptViewController: UIViewControllerComponent, EDocsStepable {
    @IBOutlet weak var infoLabel: UILabelComponent!
    @IBOutlet weak var whyLabel: UILabelComponent!
    @IBOutlet weak var goPaperlessButton: UIButtonComponent!
    @IBOutlet weak var noThanksButton: UIButtonComponent!
    @IBOutlet weak var learnMoreButton: UIButtonComponent!
    @IBOutlet weak var logoContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var centerIconView: CenterIconView!

    private let promptConfiguration: EDocsPromptConfiguration
    private let edocsService: EDocsService
    private let edocsOptions: EDocOptions
    
    weak var edocsFlowDelegate: EDocsFlowDelegate?
    
    init(config: ComponentConfig,
         promptConfiguration: EDocsPromptConfiguration,
         edocsOptions: EDocOptions,
         edocsService: EDocsService) {
        self.promptConfiguration = promptConfiguration
        self.edocsOptions = edocsOptions
        self.edocsService = edocsService

        super.init(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: EDocsBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.image = promptConfiguration.logoImage
        centerIconView.imageView.image = promptConfiguration.centerIcon
        infoLabel.text = promptConfiguration.infoLabelText
        whyLabel.text = promptConfiguration.whyLabelText
        goPaperlessButton.setTitle(promptConfiguration.submitButtonText, for: .normal)
        noThanksButton.setTitle(promptConfiguration.declineButtonText, for: .normal)
        learnMoreButton.setTitle(promptConfiguration.learnMoreButtonText, for: .normal)
    }
    
    @IBAction func goPaperlessButtonPressed(_ sender: UIButtonComponent) {
        cancelables.cancel()
        edocsFlowDelegate?.edocsPromptAccepted()
    }
    
    @IBAction func noThanksPressed(_ sender: UIButton) {
        cancelables.cancel()

        // The following network requests are fire and forget items.
        // We don't want to stop the user from moving on in the flow because
        // declining to enroll in EDocs failed. As such, we send these requests
        // and then move on without handling the response.
        if edocsOptions.contains(.estatements) {
           _ = edocsService
            .declineEDocs(for: .statement)
            .subscribe()
        }

        if edocsOptions.contains(.goPaperless) {
            
            _ = edocsService
             .declineEDocs(for: .statement)
             .subscribe()
        }

        if edocsOptions.contains(.notices) {
            _ = edocsService
                .declineEDocs(for: .notice)
                .subscribe()
        }

        if edocsOptions.contains(.taxDocs) {
            _ = edocsService
                .declineEDocs(for: .tax)
                .subscribe()
        }

        edocsFlowDelegate?.edocsPromptDeclined()
    }

    @IBAction func learnMoreButtonPressed(_ sender: UIButtonComponent) {
        let learnMore = UINavigationControllerComponent(
            rootViewController: EDocsLearnMoreViewController(
                l10nProvider: l10nProvider,
                componentStyleProvider: componentStyleProvider
            )
        )

        present(learnMore, animated: true, completion: nil)
    }
}

extension EDocsPromptViewController: TrackableScreen {
    var screenName: String {
        return "LoginFlow/Edoc"
    }
}
