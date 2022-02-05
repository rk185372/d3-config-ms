//
//  InAppRatingService.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import Network
import RxSwift

protocol InAppRatingService {
    func shouldPrompt() -> Single<ShouldPromptResponse>
    func userPrompted(_ promptedRequest: UserPromptedRequest) -> Completable
}
