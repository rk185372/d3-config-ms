//
//  NetworkThemeLoader.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/2/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class NetworkThemeLoader: ThemeLoader {
    
    private let bag = DisposeBag()
    private let path: String
    private let baseUrl: URL
    
    init(baseUrl: URL, path: String) {
        self.baseUrl = baseUrl
        self.path = path
    }
    
    func loadTheme() -> Single<[String: Any]> {
        return URLSession
            .shared
            .rx
            .json(request: URLRequest(url: baseUrl.appendingPathComponent(path)))
            .map { $0 as! [String: Any] }
            .asSingle()
    }
}

final class NetworkWebThemeLoader: WebThemeLoader {
    
    private let bag = DisposeBag()
    private let path: String
    private let baseUrl: URL
    
    init(baseUrl: URL, path: String) {
        self.baseUrl = baseUrl
        self.path = path
    }
    
    func loadWebTheme() -> Single<Data> {
        return URLSession
            .shared
            .rx
            .data(request: URLRequest(url: baseUrl.appendingPathComponent(path)))
            .asSingle()
    }
}
