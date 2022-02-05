//
//  AnimatableTitleTextField.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/9/20.
//

import UIKit
import RxSwift
import RxRelay
import Dip
import DependencyContainerExtension
import Localization
import JVFloatLabeledTextField

open class AnimatableTitleTextField: JVFloatLabeledTextField, Stylable, NibInjectable {
    @IBInspectable var style: String?
    @IBInspectable var l10nKey: String?

    private var l10nProvider: L10nProvider!
    private var componentStyleProvider: ComponentStyleProvider!
    private var reactiveFontObserver: ReactiveFontObserver!
    private let bag = DisposeBag()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupObservables()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        // This is an unfortunate hack that has to be done because for
        // some unknown reason, awakeFromNib does not get swizzled with
        // UITextField yet it does with everything else. Until we can
        // figure out why, or change how we do this, this solution is
        // the least disruptive.
        for container in DependencyContainer.nibInjectableContainers {
            do {
                try injectDependenciesFrom(container)
                break
            } catch { }
        }
        setupObservables()
        configureComponent()
    }

    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.configureComponent()
            self.setNeedsLayout()
        }
    }

    public func configureComponent(withStyle styleKey: AnimatableTitleTextFieldStyleKey? = nil) {
        var newStyle: AnimatableTitleTextFieldStyleKey

        if let styleKey = styleKey {
            newStyle = styleKey
            self.style = styleKey.rawValue
        } else {
            newStyle = AnimatableTitleTextFieldStyleKey(rawValue: style!)!
        }

        if let l10nKey = l10nKey {
            text = l10nProvider.localize(l10nKey, parameterMap: nil)
        }

        let componentStyle: AnimatableTitleTextFieldStyle = componentStyleProvider[newStyle.rawValue]
        componentStyle.style(component: self)
    }

    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        l10nProvider = try container.resolve()
        componentStyleProvider = try container.resolve()
    }

    private func setupObservables() {
        reactiveFontObserver = ReactiveFontObserver(originalFont: font!)
        reactiveFontObserver.font.drive(rx.font).disposed(by: bag)
    }

    func updateOriginalFont(font: UIFont) {
        reactiveFontObserver.updateOriginalFont(font: font)
    }
}
