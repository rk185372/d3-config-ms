//
//  AccountCircleStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/4/18.
//

import Foundation

public struct AccountCircleStyle: ComponentStyle, Decodable, Equatable {
    public let background: ComponentBackground
    public let label: LabelStyle
    
    public func style(component: AccountCircle) {
        component.circleView.background = background
        label.style(component: component.label)
    }
}
