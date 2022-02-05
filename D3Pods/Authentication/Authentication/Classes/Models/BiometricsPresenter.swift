//
//  BiometricsPresenter.swift
//  Authentication
//
//  Created by Chris Carranza on 8/14/18.
//

import Foundation
import ComponentKit
import Biometrics
import Localization
import ViewPresentable
import Views

protocol BiometricsPresenterDelegate: class {
    func biometricButtonPressed()
}

final class BiometricsPresenter: ViewPresentable {
    
    private let supportedBiometricType: SupportedBiometricType
    private let l10nProvider: L10nProvider
    private let spinner = LoadingView(activityIndicatorColor: UIColor.black)
    weak var delegate: BiometricsPresenterDelegate?
    
    init(supportedBiometricType: SupportedBiometricType,
         l10nProvider: L10nProvider,
         delegate: BiometricsPresenterDelegate?) {
        self.supportedBiometricType = supportedBiometricType
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }
    
    func createView() -> BiometricsView {
        return AuthenticationBundle.bundle.loadNibNamed("BiometricsView", owner: nil, options: nil)!.first as! BiometricsView
    }
    
    func configure(view: BiometricsView) {
        view.title.text = l10nProvider.localize("login.fingerprint.ios.label")
        view.tappableContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonPressed(sender:))))
        
        let accessibilityLabel = (supportedBiometricType == .faceId)
            ? l10nProvider.localize("login.faceid.ios.accessibility.label")
            : l10nProvider.localize("login.fingerprint.ios.accessibility.label")
        
        view.accessibilityLabel = accessibilityLabel
        view.accessibilityTraits = .button
        
        setupSpinner(view: view)
    }
    
    @objc private func buttonPressed(sender: Any?) {
        delegate?.biometricButtonPressed()
        startSpinner()
    }
    
    private func setupSpinner(view: BiometricsView) {
        view.tappableContainer.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.edges.equalTo(view.tappableContainer)
        }
        spinner.isHidden = true
    }
    
    public func startSpinner() {
        spinner.isHidden = false
        spinner.spinner.startAnimating()
        let alpha: CGFloat = (supportedBiometricType == .faceId) ? 0.9 : 0.8
        spinner.backgroundColor = UIColor(white: 1, alpha: alpha)
    }
    
    public func stopSpinner() {
        spinner.spinner.stopAnimating()
        spinner.isHidden = true
        spinner.backgroundColor = .clear
    }
}

extension BiometricsPresenter: Equatable {
    static func ==(lhs: BiometricsPresenter, rhs: BiometricsPresenter) -> Bool {
        return true
    }
}
