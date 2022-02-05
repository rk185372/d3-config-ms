//
//  UITableViewComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 11/14/18.
//

import UIKit
import Dip
import DependencyContainerExtension
import TPKeyboardAvoiding

public final class UITableViewComponent: TPKeyboardAvoidingTableView, Stylable, NibInjectable {

    @IBInspectable var componentStyle: String?
    
    private var componentStyleProvider: ComponentStyleProvider!
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    init(componentStyleProvider: ComponentStyleProvider) {
        super.init(frame: .zero, style: .plain)
        self.componentStyleProvider = componentStyleProvider
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
        if let style = componentStyle {
            let anyComponentStyle: AnyComponentStyle = componentStyleProvider[style]
            anyComponentStyle.style(component: self)
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }

}
