//
//  ChallengeServiceBridge.swift
//  Authentication
//
//  Created by Chris Carranza on 6/28/18.
//

import APITransformer
import Foundation
import Network
import Wrap

final class ChallengeServiceBridge {
    enum Error: Swift.Error {
        case invalidDictionary
        case invalidStringConversion
        case invalidDataConversion
    }
    
    let transformer: APITransformer
    
    init(transformer: APITransformer) {
        self.transformer = transformer
    }

    func handleNewMFAMethodSelection(challenge: ChallengeRequest) throws -> String {
        let jsonChallenge = try wrap(challenge)
        let dataChallenge = try JSONSerialization.data(withJSONObject: jsonChallenge, options: [])

        guard let sendString = String(data: dataChallenge, encoding: .utf8) else { throw Error.invalidStringConversion }

        return transformer.userResponseToServerResponse(sendString)
    }
    
    func prepareSubmitRequest(challenge: ChallengeRequest) throws -> [String: Any] {
        let jsonChallenge = try wrap(challenge)
        let dataChallenge = try JSONSerialization.data(withJSONObject: jsonChallenge, options: [])
        
        guard let sendString = String(data: dataChallenge, encoding: .utf8) else { throw Error.invalidStringConversion }
        
        let stringResult = transformer.userResponseToServerResponse(sendString)
        
        guard let dataResult = stringResult.data(using: .utf8) else { throw Error.invalidDataConversion }
        
        let jsonResult = try JSONSerialization.jsonObject(with: dataResult, options: [])
        guard let dictResult = jsonResult as? [String: Any] else { throw Error.invalidDictionary }
        
        return dictResult
    }
    
    func processResults(data: Data) throws -> ChallengeResponse {
        guard let string: String = String(data: data, encoding: .utf8) else { throw Error.invalidStringConversion }
        
        let responseString = transformer.serverResponseToChallengeJSON(string)
        
        guard let responseData = responseString.data(using: .utf8) else { throw Error.invalidDataConversion }
        return try JSONDecoder().decode(ChallengeResponse.self, from: responseData)
    }
}
