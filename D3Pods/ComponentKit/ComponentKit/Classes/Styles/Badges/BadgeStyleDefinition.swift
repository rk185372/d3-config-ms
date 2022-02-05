//
//  BadgeStyleDefinition.swift
//  ComponentKit
//
//  Created by Chris Carranza on 12/3/18.
//

import Foundation

public struct BadgeStyleDefinition: Decodable, Equatable {
    public let backgroundColor: DecodableColor
    public let textColor: DecodableColor
    public let textSize: CGFloat?
}
