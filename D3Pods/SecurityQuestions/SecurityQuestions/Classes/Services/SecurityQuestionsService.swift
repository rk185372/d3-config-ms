//
//  SecurityQuestionsService.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/4/18.
//

import Foundation
import RxSwift

public protocol SecurityQuestionsService {
    func getSecurityQuestions() -> Single<[SecurityQuestion]>
    func postSecurityQuestions(questions: [[String: Any?]]) -> Single<Void>
}
