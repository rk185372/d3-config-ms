//
//  API+FeatureTour.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/18/21.
//

import Foundation
import Network
import Utilities

extension API {
    enum FeatureTour {
        static func activeFeaturedDemos() -> Endpoint<[ActiveDemo]> {
            return Endpoint(method: .get, path: "v4/feature-tour/demos/featured/active")
        }
        
        static func activityRecords(featureId: String) -> Endpoint<[DemoActivityRecord]> {
            return Endpoint(method: .get, path: "v4/feature-tour/activity-records/\(featureId)")
        }
        
        static func createActivityRecord(featureId: String) -> Endpoint<DemoActivityRecord> {
            return Endpoint(method: .post, path: "v4/feature-tour/activity-records/create/\(featureId)")
        }
    }
}
