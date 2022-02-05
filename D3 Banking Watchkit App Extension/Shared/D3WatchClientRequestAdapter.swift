//
//  D3ClientRequestAdapter.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/18/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Alamofire
import Foundation
import Utilities

final class D3WatchClientRequestAdapter: RequestAdapter {
    private let uuid: D3UUID

    init(uuid: D3UUID) {
        self.uuid = uuid
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(uuid.uuidString, forHTTPHeaderField: "d3-device-uuid")

        return urlRequest
    }
}
