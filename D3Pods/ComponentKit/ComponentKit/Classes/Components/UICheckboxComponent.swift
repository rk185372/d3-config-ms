//
//  UICheckboxComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 8/22/18.
//

import Foundation
import M13Checkbox
import Dip
import DependencyContainerExtension

public final class UICheckboxComponent: M13Checkbox, Stylable, NibInjectable {
    @IBInspectable public var style: String?
    @IBInspectable public var checkedAccessibilityText: String? = "checked"
    @IBInspectable public var uncheckedAccessibilityText: String? = "unchecked"
    
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
    
    public override func setCheckState(_ newState: M13Checkbox.CheckState, animated: Bool) {
        super.setCheckState(newState, animated: animated)
        
        guard checkState != newState else { return }
        
        switch newState {
        case .checked:
            accessibilityValue = checkedAccessibilityText
        case .unchecked:
            accessibilityValue = uncheckedAccessibilityText
        default:
            accessibilityValue = "-"
        }
    }
}
