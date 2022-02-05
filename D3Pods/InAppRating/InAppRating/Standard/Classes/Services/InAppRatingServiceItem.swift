//
//  InAppRatingServiceItem.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import Network
import Utilities
import RxSwift

final class InAppRatingServiceItem: InAppRatingService {
    private let client: ClientProtocol
    
    init(client: ClientProtocol) {
        self.client = client
    }
    
    func shouldPrompt() -> Single<ShouldPromptResponse> {
        return client.request(API.InAppRating.shouldPrompt())
    }
    
    func userPrompted(_ promptedRequest: UserPromptedRequest) -> Completable {
        return client.request(API.InAppRating.userPrompted(promptedRequest)).asCompletable()
    }
}
