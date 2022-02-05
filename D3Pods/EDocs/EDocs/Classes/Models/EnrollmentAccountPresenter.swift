//
//  EnrollmentAccountPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 1/8/20.
//

import Foundation
import ViewPresentable

struct EnrollmentAccountPresenter: ViewPresentable {

    private let account: EDocsPromptAccount

    init(account: EDocsPromptAccount) {
        self.account = account
    }

    func createView() -> EnrollmentAccountView {
        return EDocsBundle
            .bundle
            .loadNibNamed("EnrollmentAccountView", owner: nil, options: nil)?
            .first as! EnrollmentAccountView
    }

    func configure(view: EnrollmentAccountView) {
        let nameText = account.accountName
            + " (\(account.accountNumber.masked()))"
        view.accountNameLabel.text = nameText
    }
}
