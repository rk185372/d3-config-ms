//
//  OnDotService.swift
//  CardControl
//
//  Created by Elvin Bearden on 4/28/21.
//

import Foundation
import RxSwift
import CardAppMobile
import Network

struct OnDotSessionResponse: Decodable {
    let sessionId: String
    let subscriberId: String
}

class OnDotService {
    private let configuration: CardControlConfiguration
    private let client: ClientProtocol
    private var sessionId: String = ""
    private var subscriberReferenceId: String = "8c5a272f-4e5e-4611-be28-5-3-3-0"

    init(configuration: CardControlConfiguration,
         client: ClientProtocol) {
        self.configuration = configuration
        self.client = client
    }

    func createSession() -> Single<CardAppUserConfiguration> {
        return client.request(API.CardControl.createSession()).map { response in
            CardAppUserConfiguration(subscriberReferenceId: response.subscriberId, ondotSessionId: response.sessionId)
        }
    }

    func renewSession() -> Single<CardAppUserConfiguration> {
        return client.request(API.CardControl.createSession()).map { response in
            CardAppUserConfiguration(subscriberReferenceId: response.subscriberId, ondotSessionId: response.sessionId)
        }
    }
}
