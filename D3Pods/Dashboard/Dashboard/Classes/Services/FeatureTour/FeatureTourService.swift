//
//  FeatureTourService.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/18/21.
//

import Foundation
import RxSwift

public protocol FeatureTourService {
    func activeFeaturedDemos() -> Single<[ActiveDemo]>
    func activityRecords(featureId: String) -> Single<[DemoActivityRecord]>
    func createActivityRecord(featureId: String) -> Single<DemoActivityRecord>
}
