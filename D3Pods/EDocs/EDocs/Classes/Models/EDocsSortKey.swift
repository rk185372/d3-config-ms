//
//  EDocsSortKey.swift
//  EDocs
//
//  Created by Branden Smith on 1/9/20.
//

import Foundation

enum EDocsSortKey: Int, Equatable {
    case goPaperless
    case estatements
    case notices
    case taxDocs
}

extension EDocsSortKey: Comparable {
    static func < (lhs: EDocsSortKey, rhs: EDocsSortKey) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
