//
//  CenterIcon.swift
//  ComponentKit
//
//  Created by Andrew Watt on 9/21/18.
//

import UIKit
import Dip
import DependencyContainerExtension

public final class CenterIconView: UIView, NibInjectable {
    @IBInspectable var style: String?
    
    private var componentStyleProvider: ComponentStyleProvider!
    
    @IBOutlet public var circleView: UIViewComponent!
    @IBOutlet public var imageView: UIImageView!
        
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
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    private func configureComponent() {
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
        invalidateIntrinsicContentSize()
    }
        
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
}
