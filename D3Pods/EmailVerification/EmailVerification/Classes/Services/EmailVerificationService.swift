//
//  EmailVerificationService.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import Foundation
import RxSwift

public protocol EmailVerificationService {
    func postPrimaryEmail(email: String) -> Single<Void>
    func cleanEmailVerify() -> Single<Void>
}
