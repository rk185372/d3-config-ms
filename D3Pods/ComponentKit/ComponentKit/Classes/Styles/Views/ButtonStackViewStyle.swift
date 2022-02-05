//
//  ButtonStackViewStyle.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/30/20.
//

import UIKit

public struct ButtonStackViewStyle: ComponentStyle, Decodable, Equatable {

    public let textColor: DecodableColor
    public let textSize: Int
    public let separatorColor: DecodableColor

    public func style(component: ButtonStackViewComponent) {
        component.arrangedSubviews.forEach { subview in
            if let subview = subview as? UIButton {
                subview.setTitleColor(textColor.color, for: .normal)
                subview.titleLabel?.font = .boldSystemFont(ofSize: CGFloat(textSize))
            } else {
                subview.backgroundColor = separatorColor.color
            }
        }
    }
}
