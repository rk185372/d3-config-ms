//
//  NoneRequestTransformer.swift
//  RequestTransformer
//
//  Created by Branden Smith on 11/25/19.
//

import Foundation
import RxSwift
import Utilities

final class NoneRequestTransformer: RequestTransformer {
    public init() {}

    func transform(_ request: URLRequest) -> Single<URLRequest> {
        return Single.just(request)
    }

    func process(_ response: HTTPURLResponse?) {}
}
