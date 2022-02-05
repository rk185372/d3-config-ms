//
//  SecurityQuestionsServiceItem.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/4/18.
//

import Foundation
import Network
import RxSwift

public final class SecurityQuestionsServiceItem: SecurityQuestionsService {

    private let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func getSecurityQuestions() -> Single<[SecurityQuestion]> {
        return client
            .request(API.SecurityQuestions.getSecurityQuestions())
            .map({ questions in
                return questions.map { SecurityQuestion(choices: $0) }
            })
    }

    public func postSecurityQuestions(questions: [[String: Any?]]) -> Single<Void> {
        let data = try! JSONSerialization.data(withJSONObject: questions, options: [])
        return client.request(API.SecurityQuestions.postSecurityQuestions(questions: data))
    }
}
