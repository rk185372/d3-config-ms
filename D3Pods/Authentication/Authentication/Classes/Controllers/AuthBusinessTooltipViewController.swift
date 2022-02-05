//
//  AuthBusinessTooltipViewController.swift
//  Authentication
//
//  Created by Jose Torres on 3/15/21.
//

import Foundation
import ComponentKit
import Localization
import RxSwift

public final class AuthBusinessTooltipViewController: AuthDialogViewController {

    @IBOutlet weak var dialogTitle: UILabelComponent!
    @IBOutlet weak var subtitle: UILabelComponent!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var item1: UILabelComponent!
    @IBOutlet weak var item2: UILabelComponent!

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider) {

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
    }

    private func setupButtons() {
        dismissButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
    }
}
