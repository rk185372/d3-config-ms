//
//  ChallengeService.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/7/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Network
import RxSwift
import Navigation

public protocol ChallengeServiceDelegate: class {
    func currentChallengeType() -> String?
}

public protocol ChallengeService: class {
    var delegate: ChallengeServiceDelegate? { get set }
    
    func getChallenge() -> Single<ChallengeResponse>
    func submit(challenge: ChallengeRequest) -> Single<ChallengeResponse>
    func submit(challenge: [String: Any]) -> Single<ChallengeResponse>
    func cancel(challenge: [String: Any]) -> Single<Data>
    func goBack(from challenge: [String: Any]) -> Single<ChallengeResponse>
    func launchPageItems(profileType: String) -> Single<[LaunchPageItem]>

}

public protocol ChallengeServiceFactory {
    func create() -> ChallengeService
}
