//
//  ViewControllerStatusBarStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 6/12/18.
//

import Foundation

public struct ViewControllerStatusBarStyle: ComponentStyle, Equatable, Decodable {
    private let hasLightText: Bool
    
    public func style(component: UIViewControllerComponent) {
        component.hasLightText = hasLightText
    }
}
