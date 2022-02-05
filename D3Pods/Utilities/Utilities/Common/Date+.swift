//
//  Date+.swift
//  Pods
//
//  Created by Elvin Bearden on 8/20/20.
//

import Foundation

public extension Date {
    static var today: Date {
        let date = Date()
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return Calendar.current.date(from: components)!
    }

    var dateOnly: Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Calendar.current.date(from: components)!
    }
}
