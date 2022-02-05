//
//  SearchRadius.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/20/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation

public typealias Miles = Double

public enum SearchRadius: Miles {
    case threeMiles = 3.0
    case fiveMiles = 5.0
    case tenMiles = 10.0
    case twentyFiveMiles = 25.0
    case fiftyMiles = 50.0
    case oneHundredMiles = 100.0
    case twoHundredFiftyMiles = 250.0
    
    public static let allCases: Set<SearchRadius> = [
		.threeMiles,
		.fiveMiles,
		.tenMiles,
		.twentyFiveMiles,
		.fiftyMiles,
		.oneHundredMiles,
		.twoHundredFiftyMiles
    ]
}

extension SearchRadius: CustomStringConvertible {
    public var description: String {
        switch self {
        case .threeMiles:
            return "3 mi"
        case .fiveMiles:
            return "5 mi"
        case .tenMiles:
            return "10 mi"
        case .twentyFiveMiles:
            return "25 mi"
        case .fiftyMiles:
            return "50 mi"
        case .oneHundredMiles:
            return "100 mi"
        case .twoHundredFiftyMiles:
            return "250 mi"
        }
    }
}

extension SearchRadius: Comparable {
    public static func < (lhs: SearchRadius, rhs: SearchRadius) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
