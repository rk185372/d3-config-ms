//
//  UIViewComponent.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/3/18.
//

import UIKit
import Dip
import DependencyContainerExtension

public final class UIViewComponent: UIView, NibInjectable {
    @IBInspectable public var style: String?
    
    var background = ComponentBackground.none

    private var componentStyleProvider: ComponentStyleProvider!
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    init(componentStyleProvider: ComponentStyleProvider) {
        super.init(frame: .zero)
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
    
    func configureComponent() {
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = layer as? CAGradientLayer {
            switch background {
            case .none:
                layer.colors = nil
                layer.locations = nil
                
            case .solid(let color):
                backgroundColor = color
                
            case .gradient(let gradient):
                layer.colors = gradient.cgColors
                layer.locations = [0, 1]
            }
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
}
