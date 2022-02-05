//
//  EDocsLegacyAccountSelectionViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/20/19.
//

import ComponentKit
import Foundation
import Logging
import UIKit

final class EDocsLegacyAccountSelectionViewController: EDocsAccountSelectionViewController {
    override func acceptButtonTouched(_ sender: UIButtonComponent) {
        let accounts = viewModel
            .presenters
            .filter { $0.isSelected }
            .map { $0.account }

        guard !accounts.isEmpty else { return }

        beginLoading(fromButton: sender)

        self.edocsFlowDelegate?.edocsEnrollmentAccepted(
            withResult: resultProvider.getEDocsResult(given: accounts)
        )
    }

    override func noThanksButtonTouched(_ sender: UIButton) {
        cancelables.cancel()

        _ = service.declineEDocs(for: .statement)
        
        edocsFlowDelegate?.edocsFlowAdvance()
    }

}
