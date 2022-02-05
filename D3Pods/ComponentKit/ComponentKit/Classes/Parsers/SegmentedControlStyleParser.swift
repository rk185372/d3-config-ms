//
//  SegmentedControlStyleParser.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/6/18.
//

import UIKit

public final class SegmentedControlStyleParser: StyleParser {
    public enum StyleKey: String, CaseIterable {
        case segmentedControlPrimaryOnDefault
    }

    public var handledKeys: [String] {
        return StyleKey.allCases.map { $0.rawValue }
    }
    
    public init() { }
    
    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(SegmentedControlStyle.self, from: json)
        
        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
