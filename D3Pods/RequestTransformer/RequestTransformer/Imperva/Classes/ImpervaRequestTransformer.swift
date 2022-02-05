//
//  ImpervaRequestTransformer.swift
//  RequestTransformer
//
//  Created by Richard Crichlow on 5/15/20.
//

import Alamofire
import distil_protection
import Foundation
import Logging
import RxSwift
import Utilities

struct ImpervaConfig: Decodable {
    let challengeURL: URL

    enum CodingKeys: String, CodingKey {
        case challengeURL
    }

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tmpURL = try container.decode(String.self, forKey: .challengeURL)

        challengeURL = URL(string: tmpURL)!
    }
}

public final class ImpervaRequestTransformer: NSObject, RequestTransformer {

    private let protection: Protection = {
        return Protection(challenge: createConfigFromBundle().challengeURL)
    }()

    public override init() {
        super.init()
        log.info("Distil SDK version", DISTIL_PROTECTION_VERSION)
    }

    private static func createConfigFromBundle() -> ImpervaConfig {
        guard let configPath = ImpervaBundle.bundle.url(forResource: "ImpervaProperties", withExtension: "json") else {
            fatalError("Missing config file for Imperva.")
        }

        let decoder = JSONDecoder()
        let url = configPath
        let contents = try! Data(contentsOf: url)

        return try! decoder.decode(ImpervaConfig.self, from: contents)
    }

    public func transform(_ request: URLRequest) -> Single<URLRequest> {
        // We use a Single to handle the asyncronous event of getting the distil token
        // To avoid freezing the main thread
        return Single<URLRequest>.create { [unowned self] observer in
            self.protection.getTokenWithCompletionHandler { (token, _) in
                var transformedRequest = request
                var headers: [String: String] = request.allHTTPHeaderFields ?? [:]

                if let token = token {
                    let distilheader = ["X-D-Token": token]
                    headers += distilheader
                    headers.forEach { entry in
                        transformedRequest.setValue(entry.value, forHTTPHeaderField: entry.key)
                    }

                    observer(.success(transformedRequest))
                    return
                }
                observer(.success(request))
            }

            return Disposables.create()
        }
    }

    public func process(_ response: HTTPURLResponse?) {}
}
