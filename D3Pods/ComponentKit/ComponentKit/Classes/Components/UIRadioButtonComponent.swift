//
//  UIRadioButtonComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 7/11/18.
//

import Foundation
import Localization
import Dip
import DependencyContainerExtension

public class UIRadioButtonComponent: UIControl, Stylable {
    
    @IBInspectable var style: String?
    @IBInspectable var l10nKey: String?
    
    private var l10nProvider: L10nProvider!
    private var componentStyleProvider: ComponentStyleProvider!
    
    internal var outerCircleLayer = CAShapeLayer()
    internal var innerCircleLayer = CAShapeLayer()
    
    @IBInspectable public var outerCircleColor: UIColor = UIColor.green {
        didSet {
            outerCircleLayer.strokeColor = outerCircleColor.cgColor
        }
    }
    @IBInspectable public var innerCircleCircleColor: UIColor = UIColor.green {
        didSet {
            setFillState()
        }
    }
    
    @IBInspectable public var outerCircleLineWidth: CGFloat = 3.0 {
        didSet {
            setCircleLayouts()
        }
    }
    @IBInspectable public var innerCircleGap: CGFloat = 3.0 {
        didSet {
            setCircleLayouts()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    // MARK: Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInitialization()
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
    
    internal var setCircleRadius: CGFloat {
        let width = bounds.width
        let height = bounds.height
        
        let length = width > height ? height : width
        return (length - outerCircleLineWidth) / 2
    }
    
    private var setCircleFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let radius = setCircleRadius
        let x: CGFloat
        let y: CGFloat
        
        if width > height {
            y = outerCircleLineWidth / 2
            x = (width / 2) - radius
        } else {
            x = outerCircleLineWidth / 2
            y = (height / 2) - radius
        }
        
        let diameter = 2 * radius
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    private var circlePath: UIBezierPath {
        return UIBezierPath(roundedRect: setCircleFrame, cornerRadius: setCircleRadius)
    }
    
    private var fillCirclePath: UIBezierPath {
        let trueGap = innerCircleGap + (outerCircleLineWidth / 2)
        return UIBezierPath(roundedRect: setCircleFrame.insetBy(dx: trueGap, dy: trueGap), cornerRadius: setCircleRadius)
        
    }
    
    private func customInitialization() {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = outerCircleColor.cgColor
        layer.addSublayer(outerCircleLayer)
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(innerCircleLayer)
        
        setFillState()
    }
    
    private func setCircleLayouts() {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.path = circlePath.cgPath
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.path = fillCirclePath.cgPath
    }
    
    // MARK: Custom
    private func setFillState() {
        if self.isSelected {
            innerCircleLayer.fillColor = innerCircleCircleColor.cgColor
        } else {
            innerCircleLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    // Overriden methods.
    public override func prepareForInterfaceBuilder() {
        customInitialization()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setCircleLayouts()
    }
    
    public override var isSelected: Bool {
        didSet {
            setFillState()
        }
    }
}

extension UIRadioButtonComponent: NibInjectable {
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        l10nProvider = try container.resolve()
        componentStyleProvider = try container.resolve()
    }
}
