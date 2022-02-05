//
//  FeatureTourServiceItem.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/18/21.
//

import Foundation
import Network
import RxSwift

public final class FeatureTourServiceItem: FeatureTourService {

    private let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }

    public func activeFeaturedDemos() -> Single<[ActiveDemo]> {
        return client.request(API.FeatureTour.activeFeaturedDemos())
    }
    
    public func activityRecords(featureId: String) -> Single<[DemoActivityRecord]> {
        return client.request(API.FeatureTour.activityRecords(featureId: featureId))
    }
    
    public func createActivityRecord(featureId: String) -> Single<DemoActivityRecord> {
        return client.request(API.FeatureTour.createActivityRecord(featureId: featureId))
    }
}
