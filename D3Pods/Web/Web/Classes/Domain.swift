//
//  Domain.swift
//  Web
//
//  Created by Andrew Watt on 7/20/18.
//

import Foundation

/// Represents a fully qualified domain name.
struct Domain {
    /// The domain label hierarchy, from lowest level to highest (the root).
    var labels: [String]

    init(domain: String) {
        self.init(labels: domain.split(separator: ".").map(String.init))
    }
    
    init(labels: [String]) {
        self.labels = labels
    }
    
    /// Checks if this domain is the same as or a subdomain of another domain.
    /// - parameters:
    ///   - ofDomain: The domain to check
    /// - returns: `true` if this is a subdomain of the other domain, or is the same domain.
    func isSubdomain(ofDomain domain: Domain) -> Bool {
        return labels.elementsEqual(domain.labels.suffix(labels.count))
    }
}
