//
//  ViewControllerNavigationBarStyleParser.swift
//  Accounts
//
//  Created by Chris Carranza on 6/1/18.
//

import Foundation

public final class ViewControllerNavigationBarStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public enum StyleKey: String, CaseIterable {
        case navigationBarOnDefault
        case navigationBarOnPrimary
        case navigationBarOnSecondary
        case navigationBarOnCta
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ViewControllerNavigationBarStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: AnyComponentStyle(style))
    }
}
