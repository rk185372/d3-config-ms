//
//  AnimatableTitleTextFieldStyle.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/9/20.
//

import Foundation

public struct AnimatableTitleTextFieldStyle: ComponentStyle, Decodable, Equatable {
    public let textColor: DecodableColor
    public let tintColor: DecodableColor?

    public func style(component: AnimatableTitleTextField) {
        component.textColor = textColor.color

        if let tint = tintColor?.color {
            component.tintColor = tint
            component.floatingLabelTextColor = tint
        }
    }
}
