//
//  Path+Comander.swift
//  Commander
//
//  Created by Branden Smith on 11/6/19.
//

import Commander
import Foundation
import PathKit

extension Path: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        if let path = parser.shift() {
            self.init(path)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }
}
