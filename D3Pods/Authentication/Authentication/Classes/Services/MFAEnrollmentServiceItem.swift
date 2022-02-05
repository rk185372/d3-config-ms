//
//  MFAEnrollmentServiceItem.swift
//  Authentication
//
//  Created by Ignacio Mariani on 01/12/2021.
//

import Foundation
import Network
import RxSwift

public final class MFAEnrollmentServiceItem: MFAEnrollmentService {
    private let client: ClientProtocol
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)

    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func disclosure() -> Single<MFAEnrollmentResponse> {
        return client.request(API.MFAEnrollment.disclosure())
    }
}
