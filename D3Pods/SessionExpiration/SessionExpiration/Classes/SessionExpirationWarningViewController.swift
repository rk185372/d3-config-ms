//
//  SessionExpirationWarningViewController.swift
//  D3 Banking
//
//  Created by Branden Smith on 9/10/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import ComponentKit
import Foundation
import Localization
import UIKit
import Utilities

protocol SessionExpirationWarningViewControllerDelegate: class {
    func logoutSelected(for viewController: SessionExpirationWarningViewController)
    func stillHereSelected(for viewController: SessionExpirationWarningViewController)
}

final class SessionExpirationWarningViewController: UIViewControllerComponent {
    weak var delegate: SessionExpirationWarningViewControllerDelegate?
    private var remainingTime: Int

    private var seconds: Int {
        return remainingTime % 60
    }

    private var minutes: Int {
        return remainingTime / 60
    }

    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var infoLabel: UILabelComponent!
    @IBOutlet weak var timerLabel: UILabelComponent!
    @IBOutlet weak var logoutButton: UIButtonComponent!
    @IBOutlet weak var stillHereButton: UIButtonComponent!

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         remainingTime: Int,
         delegate: SessionExpirationWarningViewControllerDelegate? = nil) {
        self.remainingTime = remainingTime
        self.delegate = delegate

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: SessionExpirationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTimerLabel()
    }

    func updateRemainingTime(withTime time: Int) {
        remainingTime = time
        updateTimerLabel()
    }

    private func updateTimerLabel() {
        let secondsStr = String(format: "%02d", seconds)
        timerLabel.text = "\(minutes):\(secondsStr)"
    }

    @IBAction func logoutButtonTouched(_ sender: UIButtonComponent) {
        delegate?.logoutSelected(for: self)
    }

    @IBAction func stillHereButtonTouched(_ sender: UIButtonComponent) {
        delegate?.stillHereSelected(for: self)
    }
}
