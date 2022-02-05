//
//  API+Messages.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation
import Network
import Utilities

public extension API {
    enum Messages {
        public static func getAlertsStats() -> Endpoint<AlertsStats> {
            // The path here is messages but we refer to the messages as
            // alerts. Therefore, we return AlertsStats here for clarity
            // everywhere else.
            return Endpoint(method: .get, path: "v3/messages/stats")
        }

        public static func getSecureMessageStats() -> Endpoint<SecureMessageStats> {
            return Endpoint(method: .get, path: "v3/messages/secure/stats")
        }
        
        public static func getApprovalStats() -> Endpoint<ApprovalsStats> {
            return Endpoint(method: .get, path: "v4/approvals/stats")
        }
    }
}
