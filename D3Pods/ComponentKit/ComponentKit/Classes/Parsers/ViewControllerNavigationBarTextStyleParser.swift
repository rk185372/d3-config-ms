//
//  ViewControllerNavigationBarTextStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/23/18.
//

import Foundation

public final class ViewControllerNavigationBarTextStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public enum StyleKey: String, CaseIterable {
        case navigationTitleOnDefault
        case navigationTitleOnPrimary
        case navigationTitleOnSecondary
        case navigationTitleOnCta
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let labelStyle = try decoder.decode(LabelStyle.self, from: json)
        let style = ViewControllerNavigationBarTextStyle(labelStyle: labelStyle)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
