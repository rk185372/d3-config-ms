//
//  TitledTextFieldStyle.swift
//  ComponentKit
//
//  Created by Branden Smith on 1/24/19.
//

import Foundation

public struct TitledTextFieldStyle: ComponentStyle, Equatable, Decodable {
    public let titleLabel: LabelStyle
    public let textField: TextFieldStyle
    public let textFieldContainerView: ViewStyle

    enum CodingKeys: CodingKey {
        case titleLabel
        case textField
        case textFieldContainerView
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleLabel = try container.decode(LabelStyle.self, forKey: .titleLabel)
        textField = try container.decode(TextFieldStyle.self, forKey: .textField)
        textFieldContainerView = try container.decode(ViewStyle.self, forKey: .textFieldContainerView)
    }

    public func style(component: TitledTextFieldComponent) {
        titleLabel.style(component: component.titleLabel)
        textField.style(component: component.textField)
        textFieldContainerView.style(component: component.textFieldContainerView)
    }
}
