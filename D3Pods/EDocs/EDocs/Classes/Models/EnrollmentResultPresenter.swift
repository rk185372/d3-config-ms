//
//  EnrollmentResultPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 1/6/20.
//

import Foundation
import UIKit
import UITableViewPresentation

struct EnrollmentResultPresenter: UITableViewPresentable {

    let successes: [EDocsPromptAccount]
    let failures: [EDocsPromptAccount]
    let confirmationConfig: EDocsConfirmationConfiguration
    let helper = EnrollmentResultHelper()

    init(successes: [EDocsPromptAccount], failures: [EDocsPromptAccount], confirmationConfig: EDocsConfirmationConfiguration) {
        self.successes = successes
        self.failures = failures
        self.confirmationConfig = confirmationConfig
    }

    func configure(cell: EDocsEnrollmentResultCell, at indexPath: IndexPath) {
        helper.setInitialState(for: cell, withTitle: confirmationConfig.sectionTitle)

        if successes.isEmpty && failures.isEmpty {
            cell.failuresStack.isHidden = false
            helper.configureFailuresStack(cell.failuresStack, statusText: confirmationConfig.failureTitle)
        } else {
            if !failures.isEmpty {
                cell.failuresStack.isHidden = false
                helper.configureFailuresStack(cell.failuresStack, statusText: confirmationConfig.failureTitle)
                helper.addAccountViews(to: cell.failuresStack, for: failures)
            }

            if !successes.isEmpty {
                cell.successStack.isHidden = false
                helper.configureSuccessesStack(cell.successStack, statusText: confirmationConfig.successTitle)
                helper.addAccountViews(to: cell.successStack, for: successes)
            }
        }
    }
}

extension EnrollmentResultPresenter: Equatable {
    static func ==(_ lhs: EnrollmentResultPresenter, _ rhs: EnrollmentResultPresenter) -> Bool {
        return lhs.successes == rhs.successes
            && lhs.failures == rhs.failures
            && lhs.confirmationConfig == rhs.confirmationConfig
    }
}

extension EnrollmentResultPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
