//
//  Stylable.swift
//  ComponentKit
//
//  Created by Chris Carranza on 4/24/18.
//

import Foundation

/// A protocol to enable a component to be styled by a ComponentStyle
public protocol Stylable {
    func style<S: ComponentStyle>(componentStyle: S) where S.Component == Self
}

extension Stylable {
    public func style<S: ComponentStyle>(componentStyle: S) where S.Component == Self {
        componentStyle.style(component: self)
    }
}
