//
//  IconButton.swift
//  ComponentKit
//
//  Created by Andrew Watt on 7/31/18.
//

import UIKit
import Utilities

public final class IconButtonComponent: UIButtonComponent {
    public enum IconAlignment {
        case left
        case right
    }

    private let iconImageView = UIImageView()
    private let marginY: CGFloat = 4
    private let marginX: CGFloat = 16

    public var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
            setNeedsLayout()
        }
    }
    
    public var iconAlignment = IconAlignment.left {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var iconSize = CGSize(width: 24, height: 24) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var iconScaling = UIView.ContentMode.scaleAspectFit {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    public override func prepareForInterfaceBuilder() {
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.addSubview(iconImageView)
        
        self.layer.masksToBounds = true
        
        iconImageView.bounds = CGRect(origin: .zero, size: iconSize)
        iconImageView.contentMode = self.iconScaling
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize = iconImage == nil ? .zero : self.iconSize
        
        // Horizontal layout, left-aligned:
        // border margin image margin title margin border
        // Right-aligned:
        // border margin title margin image margin border
        
        let center = self.bounds.center
        
        let iconCenterX = { () -> CGFloat in
            switch iconAlignment {
            case .left:
                return borderWidth + marginX + (iconSize.width / 2)
            case .right:
                return bounds.width - borderWidth - marginX - (iconSize.width / 2)
            }
        }()

        iconImageView.bounds = CGRect(origin: .zero, size: iconSize)
        iconImageView.center = center.withX(iconCenterX)
        iconImageView.contentMode = self.iconScaling
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            let titleCenterX = { () -> CGFloat in
                switch iconAlignment {
                case .left:
                    return borderWidth
                        + marginX
                        + iconSize.width
                        + (iconImage == nil ? 0.0 : marginX)
                        + (titleLabel.bounds.width / 2)
                case .right:
                    return borderWidth
                        + marginX
                        + (titleLabel.bounds.width / 2)
                }
            }()
            titleLabel.center = center.withX(titleCenterX)
        }
    }
    
    private var iconCenterX: CGFloat {
        let iconSize = iconImage == nil ? .zero : self.iconSize
        switch iconAlignment {
        case .left:
            return borderWidth + marginX + (iconSize.width / 2)
        case .right:
            return bounds.width - borderWidth - marginX - (iconSize.width / 2)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let iconSize = iconImage == nil ? .zero : self.iconSize
        let marginXMultiplier: CGFloat = iconImage == nil ? 2.0 : 3.0
        let marginSize = CGSize(width: marginX * marginXMultiplier, height: marginY * 2)
        let borderSize = CGSize(width: borderWidth, height: borderWidth)
        
        let titleSize = self.titleLabel?.intrinsicContentSize ?? .zero
        
        let contentSize = CGSize(width: iconSize.width + titleSize.width, height: max(iconSize.height, titleSize.height))
        
        return contentSize + marginSize + borderSize
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.invalidateIntrinsicContentSize()
    }
}

public extension CGPoint {
    func withX(_ x: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: self.y)
    }
    
    func withY(_ y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: y)
    }
}

public extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

public extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
