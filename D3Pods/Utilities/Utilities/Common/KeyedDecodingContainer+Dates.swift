//
//  KeyedDecodingContainer+Dates.swift
//  Utilities
//
//  Created by Chris Carranza on 1/26/18.
//

import Foundation

public protocol CodableDateFormatter {
    func date(from string: String) -> Date?
}

extension DateFormatter: CodableDateFormatter {}
extension ISO8601DateFormatter: CodableDateFormatter {}

extension KeyedDecodingContainer {
    public func decode(_ type: Date.Type,
                       forKey key: KeyedDecodingContainer.Key,
                       dateFormatter: CodableDateFormatter) throws -> Date {
        let string = try decode(String.self, forKey: key)
        if let date = dateFormatter.date(from: string) {
            return date
        } else if let date = string.asDate() {
            return date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
    }
    
    public func decodeIfPresent(_ type: Date.Type,
                                forKey key: KeyedDecodingContainer.Key,
                                dateFormatter: CodableDateFormatter) throws -> Date? {
        guard let string = try decodeIfPresent(String.self, forKey: key) else { return nil }
        return dateFormatter.date(from: string) ?? string.asDate()
    }
}
