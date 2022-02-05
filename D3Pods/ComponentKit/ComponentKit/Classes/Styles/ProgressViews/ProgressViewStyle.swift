//
//  ProgressViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/25/18.
//

import UIKit

public struct ProgressViewStyle: ComponentStyle, Decodable, Equatable {
    let color: DecodableColor
    
    public func style(component: UIProgressViewComponent) {
        component.progressTintColor = color.color
    }
}
