//
//  ContentViewDelegate.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import Foundation

public protocol ContentViewDelegate: class {
    func proceedToNextScreen()
    func proceedToLogin()
}
