//
//  RDCSectionHeaderView.swift
//  Pods
//
//  Created by Chris Carranza on 11/14/18.
//

import UIKit
import ComponentKit
import Dip
import DependencyContainerExtension
import Utilities

final class RDCSectionHeaderView: UITableViewHeaderFooterView, NibInjectable {
    @IBInspectable var style: String?
    
    private var componentStyleProvider: ComponentStyleProvider!
    
    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var topDividerView: UIView!
    @IBOutlet weak var topDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomDividerView: UIView!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureComponent()
    }
    
    private func configureComponent() {
        topDividerViewHeightConstraint.setConstantToPixelWidth()
        bottomDividerViewHeightConstraint.setConstantToPixelWidth()
        
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        componentStyleProvider = try container.resolve()
    }
}
