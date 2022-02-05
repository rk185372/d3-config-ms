//
//  URL+.swift
//  Utilities
//
//  Created by Andrew Watt on 7/18/18.
//

import Foundation

public extension URL {
    /// Creates a `URL` from `self` with all path components deleted.
    /// - returns: a `URL` with all path components deleted, or `nil` if such a URL cannot be
    ///            constructed
    func deletingAllPathComponents() -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        components.path = ""
        return components.url
    }
}
