//
//  SelectionBoxStyle.swift
//  ComponentKit
//
//  Created by Branden Smith on 1/22/19.
//

import Foundation

public struct SelectionBoxStyle: ComponentStyle, Decodable, Equatable {
    let titleLabel: LabelStyle
    let valueLabel: LabelStyle
    let valueView: ViewStyle

    public func style(component: SelectionBox) {
        titleLabel.style(component: component.titleLabel)
        valueLabel.style(component: component.valueLabel)
        valueView.style(component: component.valueView)
    }
}
