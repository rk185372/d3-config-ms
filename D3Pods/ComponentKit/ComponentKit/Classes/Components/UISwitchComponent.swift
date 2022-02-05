//
//  UISwitchComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/4/18.
//

import UIKit
import Dip
import DependencyContainerExtension

public final class UISwitchComponent: UISwitch, Stylable, NibInjectable {
    @IBInspectable var brandingStyle: String?
    
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
        if let brandingStyle = brandingStyle {
            let componentStyle: AnyComponentStyle = componentStyleProvider[brandingStyle]
            componentStyle.style(component: self)
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
}
