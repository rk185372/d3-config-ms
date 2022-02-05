//
//  MFAEnrollmentServiceItemFactory.swift
//  Authentication
//
//  Created by Ignacio Mariani on 01/12/2021.
//

import Foundation
import Network
import AuthChallengeNetworkInterceptorApi

final class MFAEnrollmentServiceItemFactory: MFAEnrollmentServiceFactory {
    private let client: ClientProtocol
    
    init(client: ClientProtocol,
         networkInterceptor: @escaping () -> ChallengeNetworkInterceptorItem) {
        self.client = client
    }
    
    func create() -> MFAEnrollmentService {
        return MFAEnrollmentServiceItem(
            client: client
        )
    }
}
