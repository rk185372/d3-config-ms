//
//  ViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import UIKit

public struct ViewStyle: ComponentStyle, Decodable, Equatable {
    public let background: ComponentBackground
    
    public func style(component: UIViewComponent) {
        component.background = background
    }
}
