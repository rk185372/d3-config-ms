//
//  D3ClientRequestAdapter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 6/21/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Alamofire
import Utilities
import Session

final class D3ClientRequestAdapter: RequestAdapter {
    private let uuid: D3UUID
    private let userSession: UserSession
    
    init(uuid: D3UUID, userSession: UserSession) {
        self.uuid = uuid
        self.userSession = userSession
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(uuid.uuidString, forHTTPHeaderField: "d3-device-uuid")
        
        if let csrf = userSession.session?.csrfToken {
            urlRequest.setValue(csrf, forHTTPHeaderField: "X-D3-Csrf")
        }
        
        return urlRequest
    }
}
