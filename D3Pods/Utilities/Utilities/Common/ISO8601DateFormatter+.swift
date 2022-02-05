//
//  ISO8601DateFormatter+.swift
//  Pods
//
//  Created by Elvin Bearden on 7/17/20.
//

import Foundation

public extension ISO8601DateFormatter {
    static let shortForm: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withTimeZone
        ]

        return formatter
    }()

    static let longForm: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withTimeZone,
            .withFractionalSeconds
        ]

        return formatter
    }()
}
