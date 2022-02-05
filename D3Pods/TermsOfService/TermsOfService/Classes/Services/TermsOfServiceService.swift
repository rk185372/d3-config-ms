//
//  TermsOfServiceService.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/5/18.
//

import Foundation
import Network
import RxSwift

public protocol TermsOfServiceService {
    func accept(termsOfService: TermsOfService) -> Single<Void>
}
