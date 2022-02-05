//
//  EnrollmentResultHelper.swift
//  EDocs
//
//  Created by Branden Smith on 1/8/20.
//

import Foundation

final class EnrollmentResultHelper {

    init() {}

    func setInitialState(for cell: EDocsEnrollmentResultCell, withTitle title: String) {
        cell.titleLabel.text = title
        cell.failuresStack.removeAllViews()
        cell.successStack.removeAllViews()
        cell.failuresStack.isHidden = true
        cell.successStack.isHidden = true
    }

    func configureFailuresStack(_ stack: UIStackView, statusText: String) {
        let image = UIImage(named: "FailureIcon", in: EDocsBundle.bundle, compatibleWith: nil)!

        addStatusView(for: stack, title: statusText, image: image, tintColor: .red)
    }

    func configureSuccessesStack(_ stack: UIStackView, statusText: String) {
        let image = UIImage(named: "SuccessIcon", in: EDocsBundle.bundle, compatibleWith: nil)!
        let greenColor = UIColor(displayP3Red: 0 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1.0)

        addStatusView(for: stack, title: statusText, image: image, tintColor: greenColor)
    }

    func addAccountViews(to stack: UIStackView, for accounts: [EDocsPromptAccount]) {
        accounts.forEach { account in
            let accountPresenter = EnrollmentAccountPresenter(account: account)
            let view = accountPresenter.createView()

            accountPresenter.configure(view: view)
            stack.addArrangedSubview(view)
        }
    }

    private func addStatusView(for stack: UIStackView, title: String, image: UIImage, tintColor: UIColor) {
        let statusPresenter = EnrollmentStatusPresnter(statusText: title, image: image, tintColor: tintColor)
        let view = statusPresenter.createView()
        statusPresenter.configure(view: view)
        stack.addArrangedSubview(view)
    }
}
