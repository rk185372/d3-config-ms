//
//  BadgeView.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/3/18.
//

import Foundation
import Dip
import DependencyContainerExtension
import BadgeSwift
import RxSwift

public final class BadgeView: BadgeSwift, NibInjectable {
    @IBInspectable var style: String?
    
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
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
    
    private func setupObservables() {
        reactiveFontObserver = ReactiveFontObserver(originalFont: font)
        reactiveFontObserver.font.drive(rx.font).disposed(by: bag)
    }
    
    func updateOriginalFont(font: UIFont) {
        reactiveFontObserver.updateOriginalFont(font: font)
    }
}
