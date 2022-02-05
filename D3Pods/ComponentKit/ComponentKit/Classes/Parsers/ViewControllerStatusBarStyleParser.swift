//
//  ViewControllerStatusBarStyleParser.swift
//  ComponentKit
//
//  Created by Chris Carranza on 6/12/18.
//

import Foundation

public final class ViewControllerStatusBarStyleParser: StyleParser {
    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public enum StyleKey: String, CaseIterable {
        case statusBarOnDefault
        case statusBarOnLogin
        case statusBarOnPrimary
        case statusBarOnCta
    }
    
    public init() {}
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ViewControllerStatusBarStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
