//
//  Path+Commander.swift
//  StyleValidator
//
//  Created by Chris Carranza on 12/19/18.
//

import Foundation
import PathKit
import Commander

extension Path: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        if let path = parser.shift() {
            self.init(path)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }
}
