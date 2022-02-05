//
//  URLOpener.swift
//  Utilities
//
//  Created by Andrew Watt on 8/13/18.
//

import Foundation
import Logging

public enum URLOpenerScheme: String, CaseIterable {
    case sms
    case tel
    case mailto
}

public protocol URLOpener {
    func open(url: URL)
}

public extension URLOpener {
    func call(phoneNumber: String) {
        if let url = URL(string: "telprompt://\(phoneNumber)") {
            open(url: url)
        }
    }
    
    func email(address: String) {
        if let url = URL(string: "mailto://\(address)") {
            open(url: url)
        }
    }
    
    func sms(phoneNumber: String) {
        if let url = URL(string: "sms://\(phoneNumber)") {
            open(url: url)
        }
    }
    
    /// Attempts to handle the given url with a set of schemes.
    /// Returns true if handled, no otherwise.
    ///
    /// - Parameters:
    ///   - url: url to handle
    ///   - schemes: schemes that should be handled
    /// - Returns: Returns true if handled, no otherwise
    @discardableResult
    func handle(url: URL,
                schemes: Set<URLOpenerScheme> = Set(URLOpenerScheme.allCases)) -> Bool {
        let urlElements = url.absoluteString.components(separatedBy: ":")
        
        guard let scheme = URLOpenerScheme(rawValue: urlElements[0]),
            schemes.contains(scheme) else {
            log.debug("Scheme not allowed, not loading")
            return false
        }
        
        log.debug("Using scheme: \(scheme)")
        
        switch scheme {
        case .tel:
            call(phoneNumber: urlElements[1])
        case .sms:
            sms(phoneNumber: urlElements[1])
        case .mailto:
            email(address: urlElements[1])
        }
        
        return true
    }
}
