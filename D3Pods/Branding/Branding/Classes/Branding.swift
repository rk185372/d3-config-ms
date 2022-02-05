//
//  Branding.swift
//  Branding
//
//  Created by Chris Carranza on 11/15/17.
//

import Foundation

public enum Branding {
    case primary
    case highlight
    
    public var color: UIColor {
        switch self {
        case .primary:
            return UIColor(red: 0, green: 118 / 255, blue: 148 / 255, alpha: 1)
        case .highlight:
            return UIColor(red: 0, green: 146 / 255, blue: 143 / 255, alpha: 1)
        }
    }
}
