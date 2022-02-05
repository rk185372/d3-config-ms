//
//  WebViewExtensionsCacheTests.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 1/31/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import XCTest
@testable import Web

final class WebViewExtensionsCacheTests: XCTestCase {

    func testMergeWithMatchingEnabledExtensions() {
        let expectation = XCTestExpectation()

        // This response matches what we know is in the testExtensions.json
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        // We expect the result to be the same as the local extensions we loaded
        let expectedResult = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        cache.getEnabledExtensions(completion: { res in
            XCTAssertEqual(res, expectedResult)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 8, enforceOrder: false)
    }

    func testMergeWithExtraNetworkExtensions() {
        let expectation = XCTestExpectation()

        // This response has an extra enabled extension in it that is not in the testExtensions.json file.
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                ),
                .init(
                    id: 402,
                    path: "https://some-path.com",
                    extensionId: 999,
                    sourceAssetId: "402",
                    assetType: "SOME ASSET TYPE",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                )
            ],
            fonts: []
        )

        // We expect the result to exclude the extra extension we put in the extensionResponse mock.
        let expectedResult = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        cache.getEnabledExtensions(completion: { res in
            XCTAssertEqual(res, expectedResult)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 8, enforceOrder: false)
    }

    func testMergeWithExtraLocalExtension() {
        let expectation = XCTestExpectation()

        // This response has a one less extension than the ones read in testExtensionsWithExtraExtension.json.
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        // There is an extra extension in the local extensions file that shouldn't be included
        // in the result of the merge. We want to check that the expected result doesn't contain
        // this extra extension.
        let expectedResult = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensionsWithExtraExtension",
            bundle: Bundle(for: type(of: self))
        )

        cache.getEnabledExtensions(completion: { res in
            XCTAssertEqual(res, expectedResult)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 8, enforceOrder: false)
    }

    func testCacheWithError() {
        let expectation = XCTestExpectation()

        // If the network call succeeds the expected result should only be
        // the extension in extensionResponse. If the network fails, the
        // result should be the items listed in the expectedResult (these match)
        // the testExtensions.json.
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                )
            ],
            fonts: []
        )

        // We expect the result to be the same as the local extensions we loaded.
        // This result matches the contents of that file.
        let expectedResult = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 399,
                    path: "https://extensions-synovusqa.d3vcloud.com/credentials-extension.js",
                    extensionId: 864,
                    sourceAssetId: "399",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: nil,
                    async: false,
                    loadOrder: 5
                )
            ],
            fonts: []
        )

        // We are going to set the service to return an error here so that we can ensure we are still
        // getting the local extensions back.
        let serviceItem = MockWebViewService(extensionResponse: extensionResponse, forceError: true)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        cache.getEnabledExtensions(completion: { res in
            XCTAssertEqual(res, expectedResult)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 8, enforceOrder: false)
    }

    func testServiceCallCountWithSuccessfulNetworkResponse() {
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        // We want to check to make sure that the service is only ever called
        // one time (that is the point of the cache), so we will assert that it hasn't
        // been called. We then create 10 subscriptions and assert that after all 10, it has only
        // been called one time.
        XCTAssertEqual(serviceItem.callCount, 0)

        for _ in 1...10 {
            cache.getEnabledExtensions(completion: { _ in })
        }

        XCTAssertEqual(serviceItem.callCount, 1)
    }

    func testServiceCallCountWithNetworkError() {
        let extensionResponse = WebViewExtensionsResponse(
            extensions: [],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse, forceError: true)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        // We know we are forcing this to error so we want to make sure that the service
        // is called everytime there is a subscription when it hasn't yet succeeded.
        XCTAssertEqual(serviceItem.callCount, 0)

        for i in 1...10 {
            cache.getEnabledExtensions(completion: { _ in })
            XCTAssertEqual(serviceItem.callCount, i)
        }
    }

    func testThatCachedValueIsAlwaysReturned() {
        let expectation = XCTestExpectation()

        let extensionResponse = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 998,
                    path: "/extension/some-extension.js",
                    extensionId: 764,
                    sourceAssetId: "998",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                ),
                .init(
                    id: 999,
                    path: "/extensions/some-other-extension.js",
                    extensionId: 765,
                    sourceAssetId: "999",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                )
            ],
            fonts: []
        )

        let expectedResult = WebViewExtensionsResponse(
            extensions: [
                .init(
                    id: 298,
                    path: "/extensions/nao-redirect-extension.js",
                    extensionId: 763,
                    sourceAssetId: "298",
                    assetType: "SCRIPT",
                    disabled: false,
                    assetVersion: "1.2.3",
                    async: true,
                    loadOrder: 3
                )
            ],
            fonts: []
        )

        let serviceItem = MockWebViewService(extensionResponse: extensionResponse)

        let cache = WebViewExtensionsCache(
            serviceItem: serviceItem,
            localExtensionsFilename: "testExtensions",
            bundle: Bundle(for: type(of: self))
        )

        expectation.expectedFulfillmentCount = 10

        for _ in 1...10 {
            cache.getEnabledExtensions(completion: { res in
                XCTAssertEqual(serviceItem.callCount, 1)
                XCTAssertEqual(res, expectedResult)

                expectation.fulfill()
            })
        }

        wait(for: [expectation], timeout: 8, enforceOrder: false)
    }
}
