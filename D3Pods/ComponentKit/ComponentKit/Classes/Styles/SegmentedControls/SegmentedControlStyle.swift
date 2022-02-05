//
//  SegmentedControlStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import UIKit

public struct SegmentedControlStyle: ComponentStyle, Decodable, Equatable {
    let color: DecodableColor
    
    public func style(component: UISegmentedControlComponent) {
        component.tintColor = color.color
    }
}
