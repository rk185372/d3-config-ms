//
//  SectionHeaderViewStyle.swift
//  ComponentKit
//
//  Created by Andrew Watt on 10/5/18.
//

import Foundation

public struct SectionHeaderViewStyle: ComponentStyle, Decodable, Equatable {
    let background: ComponentBackground
    let label: LabelStyle
    
    public func style(component: SectionHeaderView) {
        component.backgroundView.background = background
        label.style(component: component.titleLabel)
    }
}
