//
//  Feature.swift
//  Permissions
//
//  Created by Andrew Watt on 10/8/18.
//

import Foundation

public struct Feature: Hashable {
    public let path: String
    
    public init(path: String) {
        self.path = path
    }
}

extension Feature {
    public static let accounts = Feature(path: "accounts")
    public static let mrdc = Feature(path: "mrdc")
    public static let locations = Feature(path: "locations")
    public static let logout = Feature(path: "logout")
    public static let feedback = Feature(path: "feedback")
    public static let cardControls = Feature(path: "self-service/card-controls")
    public static let moneyMap = Feature(path: "financial-wellness/money-map")
    public static let pulse = Feature(path: "financial-wellness/pulse")
}
