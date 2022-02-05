//
//  Navigation.swift
//  NavigationComponentBuilderCore
//
//  Created by Branden Smith on 11/6/19.
//

import Foundation

struct Navigation: Codable {
    public let name: String
    public let position: Int
    public let enabled: Bool
    public let web: WebComponent?
}
