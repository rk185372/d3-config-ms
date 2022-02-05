//
//  CenterIconViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 9/21/18.
//

import Foundation

public struct CenterIconViewStyle: ComponentStyle, Decodable, Equatable {
    public let background: ComponentBackground
    public let color: DecodableColor
    
    public func style(component: CenterIconView) {
        component.circleView.background = background
        component.imageView.tintColor = color.color
    }
}
