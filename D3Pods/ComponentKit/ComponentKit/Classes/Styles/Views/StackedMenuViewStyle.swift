//
//  StackedMenuViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/20/18.
//

import Foundation

public struct StackedMenuViewStyle: ComponentStyle, Decodable, Equatable {
    private let background: ComponentBackground
    private let borderColor: DecodableColor?
    private let titleTextColor: DecodableColor?
    private let titleTextSize: CGFloat
    private let subtitleTextColor: DecodableColor?
    private let subtitleTextSize: CGFloat
    private let iconColor: DecodableColor
    
    public func style(component: StackedMenuView) {
        component.background = background
        
        component.titleLabel.font = component.titleLabel.font.withSize(titleTextSize)
        component.subtitleLabel.font = component.subtitleLabel.font.withSize(subtitleTextSize)

        // Note, if the component is styled before the image is set the
        // iconColor will not take effect. The component will need to be re-styled
        // after the image is set.
        if let image = component.imageView.image {
            component.imageView.image = colorComponentImage(image: image)
        }
        
        if let titleTextColor = titleTextColor?.color {
            component.titleLabel.textColor = titleTextColor
            component.imageView.tintColor = titleTextColor
        }

        if let subtitleTextColor = subtitleTextColor?.color {
            component.subtitleLabel.textColor = subtitleTextColor
        }

        if let borderColor = borderColor?.color {
            component.borderColor = borderColor
            component.borderWidth = 1
        }
        
        component.layerCornerRadius = 2
    }

    private func colorComponentImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return image }
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        guard let mask = image.cgImage else { return image }
        context.clip(to: rect, mask: mask)

        iconColor.color.setFill()
        context.fill(rect)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }

        UIGraphicsEndImageContext()

        return newImage
    }
}
