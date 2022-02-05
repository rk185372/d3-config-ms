//
//  WKWebView+Rx.swift
//  Utilities
//
//  Created by Andrew Watt on 10/24/18.
//

import Foundation
import WebKit
import RxSwift

public extension Reactive where Base == WKWebView {
    var url: Observable<URL> {
        return values(at: \.url).skipNil()
    }
    
    var canGoBack: Observable<Bool> {
        return values(at: \.canGoBack)
    }
    
    var canGoForward: Observable<Bool> {
        return values(at: \.canGoForward)
    }
    
    var estimatedProgress: Observable<Double> {
        return values(at: \.estimatedProgress)
    }
    
    var isLoading: Observable<Bool> {
        return values(at: \.isLoading)
    }
    
    var title: Observable<String?> {
        return values(at: \.title)
    }
}
