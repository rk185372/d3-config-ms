//
//  SelectionBoxStyleParser.swift
//  ComponentKit
//
//  Created by Branden Smith on 1/22/19.
//

import Foundation

public final class SelectionBoxStyleParser: StyleParser {
    public var handledKeys: [String] {
        return SelectionBoxStyleKey.allCases.map { $0.rawValue }
    }

    public init() { }

    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(SelectionBoxStyle.self, from: json)

        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
