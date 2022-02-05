//
//  API+OOB.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/29/20.
//

import Foundation
import Network
import Session

public extension API {
    enum OobDestinations {
        public static func putOutOfBandDestinations(request: UserProfile) -> Endpoint<Void> {
            let data = try! JSONSerialization.jsonObject(with: JSONEncoder().encode(request), options: []) as? [String: Any]
            return Endpoint(
                method: .put,
                path: "v3/users/current/destinations/reset",
                parameters: data
            )
        }
    }
}
