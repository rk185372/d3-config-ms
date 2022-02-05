//
//  UIPageControlComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 1/29/19.
//

import Foundation
import UIKit
import Dip
import DependencyContainerExtension

public final class UIPageControlComponent: UIPageControl, NibInjectable, Stylable {
    
    @IBInspectable public var style: String?
    
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
