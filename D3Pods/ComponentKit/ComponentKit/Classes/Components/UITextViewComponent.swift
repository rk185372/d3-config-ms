//
//  UITextViewComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/10/18.
//

import UIKit
import RxSwift
import RxRelay
import Dip
import DependencyContainerExtension
import Localization

public final class UITextViewComponent: UITextView, Stylable, NibInjectable {
    @IBInspectable var style: String?
    @IBInspectable var l10nKey: String?
    
    private var l10nProvider: L10nProvider!
    private var componentStyleProvider: ComponentStyleProvider!
    private var reactiveFontObserver: ReactiveFontObserver!
    private let bag = DisposeBag()
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupObservables()
        configureComponent()
    }
    
    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.configureComponent()
            self.setNeedsLayout()
        }
    }
    
    private func configureComponent() {
        if let l10nKey = l10nKey {
            text = l10nProvider.localize(l10nKey, parameterMap: nil)
        }
        
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
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
