//
//  AnimatableTitleTextFieldStyleParser.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 11/9/20.
//

import Foundation

public final class AnimatableTitleTextFieldStyleParser: StyleParser {
    public var handledKeys: [String] {
        return AnimatableTitleTextFieldStyleKey.allCases.map { $0.rawValue }
    }

    public init () { }

    public func parse(key: String, json: Data, decoder: JSONDecoder) throws -> StyleParseResult {
        let style = try decoder.decode(AnimatableTitleTextFieldStyle.self, from: json)

        return StyleParseResult(mapKey: key, mapValue: style)
    }
}
