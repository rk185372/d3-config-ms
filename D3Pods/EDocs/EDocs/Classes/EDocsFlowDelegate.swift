//
//  EDocsFlowDelegate.swift
//  EDocs
//
//  Created by Andrew Watt on 8/27/18.
//

import Foundation

protocol EDocsFlowDelegate: class {
    func edocsPromptDeclined()
    func edocsPromptAccepted()
    func edocsEnrollmentAccepted(withResult result: EDocsSelectionResult)
    func edocsFlowAdvance()
}
