//
//  ViewControllerNavigationBarTextStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/23/18.
//

import Foundation

public struct ViewControllerNavigationBarTextStyle: ComponentStyle, Equatable {
    private let labelStyle: LabelStyle
    
    init(labelStyle: LabelStyle) {
        self.labelStyle = labelStyle
    }
    
    public func style(component: UIViewControllerComponent) {
        component.navigationStyleItem.titleColor = labelStyle.textColor
        
        if let font = component.navigationStyleItem.titleFont {
            component.navigationStyleItem.titleFont = font.withSize(labelStyle.textSize)
        } else {
            component.navigationStyleItem.titleFont = UIFont.systemFont(ofSize: labelStyle.textSize, weight: .semibold)
        }
        
        component.navigationStyleItem.tintColor = labelStyle.textColor
    }
}
