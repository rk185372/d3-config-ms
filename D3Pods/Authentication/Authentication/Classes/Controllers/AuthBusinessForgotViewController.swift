//
//  AuthBusinessForgotViewController.swift
//  Authentication
//
//  Created by Jose Torres on 3/15/21.
//

import Foundation
import ComponentKit
import Localization
import RxSwift

public final class AuthBusinessForgotViewController: AuthDialogViewController {

    @IBOutlet weak var dialogTitle: UILabelComponent!
    @IBOutlet weak var userNameSubtitle: UILabelComponent!
    @IBOutlet weak var userNameDescription: UILabelComponent!
    @IBOutlet weak var passwordSubtitle: UILabelComponent!
    @IBOutlet weak var passwordDescription: UILabelComponent!
    @IBOutlet weak var mainButton: UIButtonComponent!
    @IBOutlet weak var dismissButton: UIButtonComponent!

    weak var delegate: AuthDialogViewControllerDelegate?

    private var url: URL?

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                url: URL?) {

        self.url = url

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AuthenticationBundle.bundle
        )
    }

    public override func viewDidLoad() {
        adjustStrings()
        setupButtons()
    }

    private func adjustStrings() {
        dialogTitle.text = dialogTitle.text?.uppercased()
        mainButton.setTitle(
            l10nProvider.localize("login.business.modal.loginHelp.button.main").uppercased(),
            for: .normal
        )
        dismissButton.setTitle(
            l10nProvider.localize("login.business.modal.loginHelp.button.dismiss").uppercased(),
            for: .normal
        )
    }

    private func setupButtons() {
        dismissButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)

        mainButton.rx.tap.bind {
            self.delegate?.authDialogViewController(self, type: .forgotUsernamePassword(url: self.url), didTap: self.url)
        }.disposed(by: bag)
    }
}
