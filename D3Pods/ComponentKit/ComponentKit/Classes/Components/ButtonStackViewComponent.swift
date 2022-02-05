//
//  ButtonStackViewComponent.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/30/20.
//

import UIKit
import Dip
import DependencyContainerExtension

public final class ButtonStackViewComponent: UIStackView, Stylable {
    @IBInspectable public var style: String?

    private var componentStyleProvider: ComponentStyleProvider!

    public required init(coder: NSCoder) {
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
        for container in DependencyContainer.nibInjectableContainers {
            do {
                try injectDependenciesFrom(container)
                break
            } catch { }
        }
        configureComponent()
    }

    public func configureComponent() {
        if let style = style {
            let componentStyle: ButtonStackViewStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
    }

    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.configureComponent()
            self.setNeedsLayout()
        }
    }

    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
}
