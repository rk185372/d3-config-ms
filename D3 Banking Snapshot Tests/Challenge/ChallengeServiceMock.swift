//
//  ChallengeServiceMock.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import MockData
import Network

@testable import D3_N3xt

final class ChallengeServiceMock: ChallengeService {    
    func getChallenge(withCompletion completion: @escaping (Result<Challenge>) -> Void) {
        completion(.success(challenge))
    }

    func submitChallenge(_ challenge: Challenge, withCompletion completion: @escaping (Result<Challenge>) -> Void) {}

    private var challenge: Challenge {
        let data: Data = try! JSONHelper.resource(named: "challenge", bundle: MockDataBundle.bundle)

        return try! JSONDecoder().decode(Challenge.self, from: data)
    }
}
