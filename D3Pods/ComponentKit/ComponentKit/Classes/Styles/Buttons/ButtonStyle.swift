//
//  ButtonStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/7/18.
//

import Foundation

struct ButtonStyle: ComponentStyle, Equatable, Decodable {
    let base: ButtonState
    let pressed: ButtonState?
    let disabled: ButtonState?
    let cornerRadius: Int
    
    func style(component: UIButtonComponent) {
        component.clipsToBounds = true
        component.imageView?.tintColor = base.textColor
        component.cornerRadius = CGFloat(cornerRadius)

        component.setTitleColor(base.textColor, for: .normal)
        component.setBackground(base.background, for: .normal)
        component.setBorderColor(base.borderColor, for: .normal)

        if let pressed = pressed {
            component.setTitleColor(pressed.textColor, for: .highlighted)
            component.setBackground(pressed.background, for: .highlighted)
            component.setBorderColor(pressed.borderColor, for: .highlighted)
        }
        
        if let disabled = disabled {
            component.setTitleColor(disabled.textColor, for: .disabled)
            component.setBackground(disabled.background, for: .disabled)
            component.setBorderColor(disabled.borderColor, for: .disabled)
        }
        
        if base.borderColor != nil {
            component.layer.borderWidth = 1
        }
    }
}
