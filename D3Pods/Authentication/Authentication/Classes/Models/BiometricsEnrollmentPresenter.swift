//
//  BiometricsEnrollmentPresenter.swift
//  Authentication
//
//  Created by Chris Carranza on 8/21/18.
//

import Foundation
import ComponentKit
import Biometrics
import Localization
import RxSwift
import ViewPresentable

protocol BiometricsEnrollmentPresenterDelegate: class {
    func biometricEnrollmentCheckboxChanged(checkbox: UICheckboxComponent)
}

final class BiometricsEnrollmentPresenter: ViewPresentable {
    private let supportedBiometricType: SupportedBiometricType
    private let l10nProvider: L10nProvider
    private var enableValue = false

    private var bag = DisposeBag()

    weak var delegate: BiometricsEnrollmentPresenterDelegate?
    
    init(supportedBiometricType: SupportedBiometricType,
         l10nProvider: L10nProvider,
         delegate: BiometricsEnrollmentPresenterDelegate?) {
        self.supportedBiometricType = supportedBiometricType
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }
    
    func createView() -> BiometricsEnrollmentView {
        return AuthenticationBundle
            .bundle
            .loadNibNamed("BiometricsEnrollmentView", owner: nil, options: nil)!
            .first as! BiometricsEnrollmentView
    }
    
    func configure(view: BiometricsEnrollmentView) {
        bag = DisposeBag()

        let tapRecognizer = UITapGestureRecognizer()
        view.titleLabel.gestureRecognizers?.forEach({ view.titleLabel.removeGestureRecognizer($0) })
        view.titleLabel.addGestureRecognizer(tapRecognizer)

        tapRecognizer
            .rx
            .event
            .bind(onNext: { (_) in
                view.checkbox?.setCheckState((self.enableValue) ? .unchecked : .checked, animated: true)
                self.enableValue.toggle()
                view.accessibilityValue = self.enableValue ? "checked" : "unchecked"
                self.delegate?.biometricEnrollmentCheckboxChanged(checkbox: view.checkbox)
            })
            .disposed(by: bag)

        let title = (supportedBiometricType == .faceId)
            ? l10nProvider.localize("login.faceid.ios.enable.text")
            : l10nProvider.localize("login.fingerprint.ios.enable.text")
        view.titleLabel.text = title
        view.accessibilityLabel = "\(title) checkbox"

        view.checkbox.checkState = enableValue ? .checked : .unchecked
        view.checkbox.isAccessibilityElement = true

        view
            .checkbox
            .rx
            .controlEvent(.valueChanged)
            .bind(onNext: { () in
                self.enableValue.toggle()
                view.accessibilityValue = self.enableValue ? "checked" : "unchecked"
                self.delegate?.biometricEnrollmentCheckboxChanged(checkbox: view.checkbox)
            })
            .disposed(by: bag)

        view.accessibilityValue = enableValue ? "checked" : "unchecked"
    }
}

extension BiometricsEnrollmentPresenter: Equatable {
    static func ==(lhs: BiometricsEnrollmentPresenter, rhs: BiometricsEnrollmentPresenter) -> Bool {
        return true
    }
}
