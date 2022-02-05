//
//  Date+Formatting.swift
//  Pods
//
//  Created by Chris Carranza on 5/18/17.
//
//

import Foundation

public extension Date {
    /// 7/14/20, 9:38 AM
    var shortStyleString: String {
        return DateFormatter.shortStyle.string(from: self)
    }
    
    /// July 14, 2020 at 9:39:18 AM CDT
    var longStyleString: String {
        return DateFormatter.longStyle.string(from: self)
    }
    
    /// July 14, 2020
    var longStyleStringExcludingTime: String {
        return DateFormatter.longStyleExcludingTime.string(from: self)
    }
    
    /// July
    var monthString: String {
        let calendar = Calendar.current
        let monthIndex = (calendar as NSCalendar).component(.month, from: self)
        return calendar.monthSymbols[monthIndex - 1]
    }

    /// Jul
    var abbreviatedMonthString: String {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: self)
        return calendar.shortMonthSymbols[monthIndex - 1]
    }
    
    /// 14
    var dayString: String {
        let calendar = Calendar.current
        let day = (calendar as NSCalendar).component(.day, from: self)
        return String(day)
    }
    
    // 2020
    var yearString: String {
        let calendar = Calendar.current
        let year = (calendar as NSCalendar).component(.year, from: self)
        return String(year)
    }
}
