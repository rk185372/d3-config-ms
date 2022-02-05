//
//  UISegmentedControlComponent.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import UIKit
import Dip
import DependencyContainerExtension
import Localization

public final class UISegmentedControlComponent: UISegmentedControl, Stylable, NibInjectable {
    @IBInspectable var style: String?
    
    private var componentStyleProvider: ComponentStyleProvider!

    public override init(frame: CGRect) {
        super.init(frame: frame)
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
}
