//
//  EDocsPostAuthStep.swift
//  EDocs
//
//  Created by Andrew Watt on 8/23/18.
//

import Foundation
import Localization
import PostAuthFlowController

final class EDocsPostAuthStep: PostAuthStep {
    private var steps: [EDocsStepable]
    private var results: [EDocsSelectionResult] = []

    weak var postAuthFlowController: PostAuthFlowController?

    public init(steps: [EDocsStepable], postAuthFlowController: PostAuthFlowController) {
        self.steps = steps
        self.postAuthFlowController = postAuthFlowController
        
        self.steps.forEach { $0.edocsFlowDelegate = self }
    }
    
    public func viewControllers() -> AnyIterator<UIViewController> {
        return AnyIterator(nextViewController)
    }
    
    private func nextViewController() -> UIViewController? {
        guard !steps.isEmpty else { return nil }

        if steps.count > 1 {
            return steps.remove(at: 0)
        }

        if let confirmation = steps.remove(at: 0) as? EDocsConfirmationViewController, !results.isEmpty {
            confirmation.results = results

            return confirmation
        }

        return nil
    }
}

extension EDocsPostAuthStep: EDocsFlowDelegate {
    func edocsEnrollmentAccepted(withResult result: EDocsSelectionResult) {
        results.append(result)

        postAuthFlowController?.advance()
    }

    func edocsPromptAccepted() {
        postAuthFlowController?.advance()
    }

    func edocsPromptDeclined() {
        // If the prompt was declined we empty remaining
        // view controllers so that the next call returns nil.
        steps.removeAll()
        postAuthFlowController?.advance()
    }

    func edocsEnrollmentCompleted(accounts: [EnrollmentResultAccount]) {
        postAuthFlowController?.advance()
    }
    
    func edocsFlowAdvance() {
        postAuthFlowController?.advance()
    }
}
