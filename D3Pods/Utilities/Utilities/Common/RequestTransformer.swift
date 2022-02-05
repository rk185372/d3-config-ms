//
//  RequestTransformer.swift
//  RequestTransformer
//
//  Created by Branden Smith on 11/15/19.
//

import Alamofire
import Foundation
import RxSwift

public protocol RequestTransformer {
    func transform(_ request: URLRequest) -> Single<URLRequest>
    func process(_ response: HTTPURLResponse?)
}
