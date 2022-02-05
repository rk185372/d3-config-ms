//
//  ChallengeServiceItemFactory.swift
//  Authentication
//
//  Created by Chris Carranza on 5/8/19.
//

import Foundation
import Network
import AuthChallengeNetworkInterceptorApi

final class ChallengeServiceItemFactory: ChallengeServiceFactory {
    
    private let client: ClientProtocol
    private let challengeServiceBridge: ChallengeServiceBridge
    private let networkInterceptor: () -> ChallengeNetworkInterceptorItem
    
    init(client: ClientProtocol,
         challengeServiceBridge: ChallengeServiceBridge,
         networkInterceptor: @escaping () -> ChallengeNetworkInterceptorItem) {
        self.client = client
        self.challengeServiceBridge = challengeServiceBridge
        self.networkInterceptor = networkInterceptor
    }
    
    func create() -> ChallengeService {
        return ChallengeServiceItem(
            client: client,
            challengeServiceBridge: challengeServiceBridge,
            networkInterceptor: networkInterceptor()
        )
    }
}
