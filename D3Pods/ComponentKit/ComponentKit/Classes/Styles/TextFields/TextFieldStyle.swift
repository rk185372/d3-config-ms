//
//  TextFieldStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/5/18.
//

import Foundation

public struct TextFieldStyle: ComponentStyle, Decodable, Equatable {
    public let textColor: DecodableColor
    public let borderStyle: Int?
    public let tintColor: DecodableColor?
    public let borderColor: DecodableColor?
    
    public func style(component: UITextFieldComponent) {
        component.textColor = textColor.color

        if let borderStyleValue = borderStyle, let border: UITextField.BorderStyle = UITextField.BorderStyle(rawValue: borderStyleValue) {
            component.borderStyle = border
        }

        if let tint = tintColor?.color {
            component.tintColor = tint
        }

        if let borderColor = borderColor?.color {
            component.borderColor = borderColor
        }
    }
}
