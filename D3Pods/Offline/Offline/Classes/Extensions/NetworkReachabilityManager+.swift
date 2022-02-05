//
//  NetworkReachabilityManager+.swift
//  Accounts
//
//  Created by Andrew Watt on 9/26/18.
//

import Foundation
import Alamofire

public extension NetworkReachabilityManager {
    convenience init?(host: String?) {
        if let host = host {
            self.init(host: host)
        } else {
            self.init()
        }
    }
}

public extension NetworkReachabilityManager.NetworkReachabilityStatus {
    var isReachable: Bool {
        if case .reachable = self {
            return true
        }
        return false
    }
    
    var isNotReachable: Bool {
        if case .notReachable = self {
            return true
        }
        return false
    }
}
