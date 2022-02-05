//
//  WebComponent.swift
//  NavigationComponentBuilderCore
//
//  Created by Branden Smith on 11/7/19.
//

import Foundation

public struct WebComponent: Codable {
    public struct SubSection: Codable {
        let title: String
        let position: Int
        let subitems: [WebComponent.Item]?
    }

    public struct Item: Codable {
        let name: String
        let title: String
        let href: String
        let role: String
        let position: Int
        let subsection: Int?
    }

    let title: String
    let href: String
    let role: String
    let subitems: [WebComponent.Item]?
    let subsections: [WebComponent.SubSection]?
}
