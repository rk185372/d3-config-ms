//
//  StackedMenuView.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/20/18.
//

import UIKit
import Dip
import DependencyContainerExtension

public final class StackedMenuView: UIView, NibInjectable {
    @IBInspectable var style: String?
    
    var background = ComponentBackground.none
    
    private var componentStyleProvider: ComponentStyleProvider!
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public weak var badgeView: BadgeView!
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
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
    
    private func loadNib() {
        guard let view = ComponentKitBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as? UIView else { return }
        
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
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
        invalidateIntrinsicContentSize()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = layer as? CAGradientLayer {
            switch background {
            case .none:
                backgroundColor = nil
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
