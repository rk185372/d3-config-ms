//
//  MockWebViewService.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 1/31/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift
@testable import Web

final class MockWebViewService: WebViewService {

    enum Error: Swift.Error {
        case fakeError
    }

    private let extensionResponse: WebViewExtensionsResponse
    private let forceError: Bool

    var callCount: Int = 0

    init(extensionResponse: WebViewExtensionsResponse, forceError: Bool = false) {
        self.extensionResponse = extensionResponse
        self.forceError = forceError
    }

    func getEnabledExtensions() -> Single<WebViewExtensionsResponse> {
        callCount += 1

        if forceError {
            return Single.error(Error.fakeError)
        }

        return Single.just(extensionResponse)
    }
}
