//
//  NSObject+Rx.swift
//  Utilities
//
//  Created by Andrew Watt on 10/24/18.
//

import Foundation
import RxSwift

public extension Reactive where Base: NSObject {
    /// Wraps a KVO observation of the specified `KeyPath` with an RxSwift
    /// `Observable`. The KVO observation is created with options `[.new]`.
    ///
    /// - Parameter keyPath: the key path to observe
    /// - Returns: an observable that emits KVO values
    func values<Value>(at keyPath: KeyPath<Base, Value>) -> Observable<Value> {
        return Observable.create { (observer) -> Disposable in
            let observation = self.base.observe(keyPath, options: [.new]) { (_, change) in
                if let newValue = change.newValue {
                    observer.onNext(newValue)
                }
            }
            return Disposables.create {
                observation.invalidate()
            }
        }
    }
}
