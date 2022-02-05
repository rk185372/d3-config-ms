//
//  EnablementServiceItem.swift
//  Enablement
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network
import Utilities
import RxSwift
import DeviceInfoService
import EnablementNetworkInterceptorApi

public final class EnablementServiceItem: EnablementService {

    private let client: ClientProtocol
    private let networkInterceptor: EnablementNetworkInterceptorItem
    
    public init(client: ClientProtocol,
                networkInterceptor: EnablementNetworkInterceptorItem) {
        self.client = client
        self.networkInterceptor = networkInterceptor
    }

    public func enableSnapshot(deviceId: Int) -> Single<EnableResponse> {
        return self.networkInterceptor
            .headers()
            .flatMap({ headers in
                self.client.request(API.Enablement.enableQuickView(deviceId: deviceId, headers: headers))
            })
    }
}
