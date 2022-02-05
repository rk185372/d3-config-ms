//
//  AuthBusinessEnrollmentViewController.swift
//  Authentication
//
//  Created by Jose Torres on 3/15/21.
//

import Foundation
import ComponentKit
import Localization
import RxSwift

public final class AuthBusinessEnrollmentViewController: AuthDialogViewController {

    @IBOutlet weak var dialogTitle: UILabelComponent!
    @IBOutlet weak var subtitle: UILabelComponent!
    @IBOutlet weak var mainButton: UIButtonComponent!
    @IBOutlet weak var dismissButton: UIButtonComponent!
    @IBOutlet weak var item1: UILabelComponent!
    @IBOutlet weak var item2: UILabelComponent!
    @IBOutlet weak var item3: UILabelComponent!
    @IBOutlet weak var item4: UILabelComponent!
    @IBOutlet weak var item5: UILabelComponent!
    @IBOutlet weak var item6: UILabelComponent!
    @IBOutlet weak var item7: UILabelComponent!
    @IBOutlet weak var item8: UILabelComponent!
    @IBOutlet weak var item9: UILabelComponent!
    @IBOutlet weak var item10: UILabelComponent!

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
        loadLocalizableStrings()
        setupButtons()
    }

    private func loadLocalizableStrings() {
        dialogTitle.text = dialogTitle.text?.uppercased()
        loadAsBulletList(item1, key: "login.business.modal.enrollment.item1")
        loadAsBulletList(item2, key: "login.business.modal.enrollment.item2")
        loadAsBulletList(item3, key: "login.business.modal.enrollment.item3")
        loadAsBulletList(item4, key: "login.business.modal.enrollment.item4")
        loadAsBulletList(item5, key: "login.business.modal.enrollment.item5")
        loadAsBulletList(item6, key: "login.business.modal.enrollment.item6")
        loadAsBulletList(item7, key: "login.business.modal.enrollment.item7")
        loadAsBulletList(item8, key: "login.business.modal.enrollment.item8")
        loadAsBulletList(item9, key: "login.business.modal.enrollment.item9")
        loadAsBulletList(item10, key: "login.business.modal.enrollment.item10")
        mainButton.setTitle(
            l10nProvider.localize("login.business.modal.enrollment.button.main").uppercased(),
            for: .normal
        )
        dismissButton.setTitle(
            l10nProvider.localize("login.business.modal.enrollment.button.dismiss").uppercased(),
            for: .normal
        )
    }

    private func loadAsBulletList(_ label: UILabelComponent, key: String) {
        var localizedString = l10nProvider.localize(key)
        if !localizedString.isEmpty {
            localizedString = "• " + localizedString
        }
        label.text = localizedString
    }

    private func setupButtons() {
        dismissButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)

        mainButton.rx.tap.bind {
            self.delegate?.authDialogViewController(self, type: .enrollment(url: self.url), didTap: self.url)
        }.disposed(by: bag)
    }
}
