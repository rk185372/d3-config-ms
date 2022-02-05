//
//  EDocOptions.swift
//  EDocs
//
//  Created by Branden Smith on 12/19/19.
//

import Foundation

struct EDocOptions: OptionSet {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let goPaperless = EDocOptions(rawValue: 1 << 0)
    static let estatements = EDocOptions(rawValue: 1 << 1)
    static let notices = EDocOptions(rawValue: 1 << 2)
    static let taxDocs = EDocOptions(rawValue: 1 << 3)
}
