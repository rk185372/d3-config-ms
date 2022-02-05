//
//  PostAuthFlow.swift
//  PostAuthFlow
//
//  Created by Chris Carranza on 7/31/18.
//

import Biometrics
import CompanyAttributes
import EDocs
import Enablement
import Foundation
import Localization
import PostAuthFlowController
import Session
import TermsOfService
import Utilities
import OutOfBand

public protocol PostAuthFlowDelegate: class {
    func postAuthFlow(advancedToViewController viewController: UIViewController?)
    func postAuthFlowCancelled()
}

public final class PostAuthFlow {

    private var viewControllerQueue = AnyIterator<UIViewController>(EmptyCollection.Iterator())
    public weak var delegate: PostAuthFlowDelegate?
    
    public init(termsOfServiceViewControllerFactory: TermsOfServiceViewControllerFactory,
                termsOfService: [TermsOfService],
                setupStepFactories: [SetupStep: PostAuthViewControllerFactory],
                setupSteps: [SetupStep],
                needsBiometricsSetup: Bool,
                needsSnapshotSetup: Bool,
                supportedBiometricsType: SupportedBiometricType,
                enableFeatureViewControllerFactory: EnableFeatureViewControllerFactory,
                edocsViewControllerFactory: EDocsViewControllerFactory,
                edocsConfigurationFactory: EDocsConfigurationFactory,
                paperlessPromptAccounts: [EDocsPromptAccount],
                estatementPromptAccounts: [EDocsPromptAccount],
                accountNoticePromptAccounts: [EDocsPromptAccount],
                promptForElectronicTaxDocuments: Bool,
                l10nProvider: L10nProvider,
                delegate: PostAuthFlowDelegate?,
                needsOOBSetUp: Bool,
                oobViewControllerFactory: OOBViewControllerFactory) {
        self.delegate = delegate

        var steps: [PostAuthStep] = []

        for step in sortedSetupSteps(setupSteps) {
            if let factory = setupStepFactories[step] {
                steps.append(LazyPostAuthStep {
                    factory.create(postAuthFlowController: self)
                })
            }
        }
        
        for tos in termsOfService {
            steps.append(LazyPostAuthStep { [weak self] in
                return termsOfServiceViewControllerFactory.create(termsOfService: tos, postAuthFlowController: self)
            })
        }
        
        if needsOOBSetUp {
            steps.append(LazyPostAuthStep { [weak self] in
                return oobViewControllerFactory.create(postAuthFlowController: self)
            })
        }
        
        if needsSnapshotSetup {
            steps.append(LazyPostAuthStep { [weak self] in
                return enableFeatureViewControllerFactory.createWithSnapshotConfiguration(postAuthFlowController: self)
            })
        }
        
        if needsBiometricsSetup {
            switch supportedBiometricsType {
            case .touchId:
                steps.append(LazyPostAuthStep { [weak self] in
                    return enableFeatureViewControllerFactory.createWithTouchIdConfiguration(postAuthFlowController: self)
                })
            case .faceId:
                steps.append(LazyPostAuthStep { [weak self] in
                    return enableFeatureViewControllerFactory.createWithFaceIdConfiguration(postAuthFlowController: self)
                })
            default: break
            }
        }        
        let paperlessAuthStepFactory = EDocsPostAuthStepFactory(
            edocsViewControllerFactory: edocsViewControllerFactory,
            edocsConfigurationFactory: edocsConfigurationFactory,
            l10nProvider: l10nProvider
        )
        let paperlessStep = paperlessAuthStepFactory.create(
            paperlessPromptAccounts: paperlessPromptAccounts,
            estatementPromptAccounts: estatementPromptAccounts,
            accountNoticePromptAccounts: accountNoticePromptAccounts,
            promptForElectronicTaxDocuments: promptForElectronicTaxDocuments,
            postAuthFlowController: self
        )

        if let paperlessStep = paperlessStep {
            steps.append(paperlessStep)
        }
        
        // Flat-map all the iterators of the steps into a single lazy iterator
        viewControllerQueue = AnyIterator(steps.map { $0.viewControllers() }.joined().makeIterator())
    }
}

extension PostAuthFlow: PostAuthFlowController {
    public func cancel() {
        delegate?.postAuthFlowCancelled()
    }
    
    public func advance() {
        delegate?.postAuthFlow(advancedToViewController: viewControllerQueue.next())
    }
}

private extension PostAuthFlow {
    func sortedSetupSteps(_ setps: [SetupStep]) -> [SetupStep] {
        // MARK: Array defining setup steps display order
        let setupStepsOrder: [SetupStep] = [
            .verifyEmail,
            .securityQuestion
        ]
        let maxPriority = setupStepsOrder.count
        let priority = Dictionary(uniqueKeysWithValues: setupStepsOrder.enumerated().map { ($0.element, $0.offset) })
        return setps.sorted { priority[$0] ?? maxPriority < priority[$1] ?? maxPriority }
    }
}
