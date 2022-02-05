//
//  ButtonStackViewStyleParser.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/30/20.
//

import Foundation

public final class ButtonStackViewStyleParser: StyleParser {
    public var handledKeys: [String] {
        return ButtonStackViewStyleKey.allCases.map { $0.rawValue }
    }

    public init() { }

    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(ButtonStackViewStyle.self, from: json)

        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
