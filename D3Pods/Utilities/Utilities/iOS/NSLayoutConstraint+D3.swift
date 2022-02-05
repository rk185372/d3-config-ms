//
//  NSLayoutConstraint+D3.swift
//  Pods
//
//  Created by Chris Carranza on 3/17/17.
//
//

import Foundation

public extension NSLayoutConstraint {
    
    ///Sets constant to 1 pixel using device screen scale
    final func setConstantToPixelWidth() {
        constant = 1 / UIScreen.main.scale
    }
}
