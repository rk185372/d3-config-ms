//
//  TaxDocsEnrollmentResultPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 1/8/20.
//

import Foundation
import UIKit
import UITableViewPresentation

struct TaxDocsEnrollmentResultPresenter: UITableViewPresentable {

    private let success: Bool
    private let confirmationConfig: EDocsConfirmationConfiguration
    private let helper = EnrollmentResultHelper()

    init(success: Bool, confirmationConfig: EDocsConfirmationConfiguration) {
        self.success = success
        self.confirmationConfig = confirmationConfig
    }

    func configure(cell: EDocsEnrollmentResultCell, at indexPath: IndexPath) {
        helper.setInitialState(for: cell, withTitle: confirmationConfig.sectionTitle)

        if success {
            cell.successStack.isHidden = false
            helper.configureSuccessesStack(cell.successStack, statusText: confirmationConfig.successTitle)
        } else {
            cell.failuresStack.isHidden = false
            helper.configureFailuresStack(cell.failuresStack, statusText: confirmationConfig.failureTitle)
        }
    }
}

extension TaxDocsEnrollmentResultPresenter: Equatable {
    static func ==(_ lhs: TaxDocsEnrollmentResultPresenter, _ rhs: TaxDocsEnrollmentResultPresenter) -> Bool {
        return lhs.success == rhs.success
            && lhs.confirmationConfig == rhs.confirmationConfig
    }
}

extension TaxDocsEnrollmentResultPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
