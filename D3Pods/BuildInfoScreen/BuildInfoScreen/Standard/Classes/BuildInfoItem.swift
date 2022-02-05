//
//  BuildInfoItem.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 12/17/18.
//

import Foundation

struct BuildInfoItem {
    let key: String
    let value: String
}

extension BuildInfoItem: Equatable {
    static func ==(_ lhs: BuildInfoItem, _ rhs: BuildInfoItem) -> Bool {
        return lhs.key == rhs.key
            && lhs.value == rhs.value
    }
}
