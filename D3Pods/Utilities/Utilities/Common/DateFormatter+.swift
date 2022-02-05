//
//  DateFormatter+.swift
//  Utilities
//
//  Created by Andrew Watt on 8/17/18.
//

import Foundation

public extension DateFormatter {
    convenience init(dateStyle: Style, timeStyle: Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
    
    convenience init(formatString: String) {
        self.init()
        self.dateFormat = formatString
    }
    
    /// MM/dd/yy, hh:mm a
    static let shortStyle = {
        return DateFormatter(dateStyle: .short, timeStyle: .short)
    }()
    
    /// MMM dd, yyyy at hh:mm a z
    static let longStyle = {
        return DateFormatter(dateStyle: .long, timeStyle: .long)
    }()
    
    /// MM/dd/yy
    static let shortStyleExcludingTime = {
           return DateFormatter(dateStyle: .short, timeStyle: .none)
    }()
    
    /// MMM dd, yyyy
    static let longStyleExcludingTime = {
        return DateFormatter(dateStyle: .long, timeStyle: .none)
    }()
    
    /// yyyy-MM-dd
    static let shortStyleDashes: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// MMM\nd
    static let abbreviatedMonthOverDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM\nd"
        return formatter
    }()
    
    /// MMM d
    static let abbreviatedMonthAndDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    /// MM/dd/yyyy 'at' hh:mm a z
    static let longStyleSlashes: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy 'at' hh:mm a z"
        return formatter
    }()
}
