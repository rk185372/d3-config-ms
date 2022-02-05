//
//  ImageViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/20/18.
//

import Foundation

public struct ImageViewStyle: ComponentStyle, Decodable, Equatable {
    public let tintColor: DecodableColor
    
    public func style(component: UIImageViewComponent) {
        component.tintColor = tintColor.color
    }
}
