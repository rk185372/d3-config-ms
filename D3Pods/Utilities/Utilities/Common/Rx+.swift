//
//  Rx+.swift
//  D3 Banking
//
//  Created by Andrew Watt on 7/10/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension ObservableType {
    /// Forwards events from `self` with history: values of the returned observable are tuples whose
    /// first member is the previous value and whose second member is the current value. The
    /// previous value will be `nil` for the first event emitted.
    ///
    /// - returns: A new observable that sends tuples containing the previous and current values
    ///            of `self`.
    func withPrevious() -> Observable<(Element?, Element)> {
        var previous: Element?
        return self.map { (element) -> (Element?, Element) in
            let pair = (previous, element)
            previous = element
            return pair
        }
    }

    /// Forwards events from `self` with history: values of the returned observable are tuples whose
    /// first member is the previous value and whose second member is the current value.
    ///
    /// The returned observable will not emit a value until `self` has received two values.
    ///
    /// - returns: A new observable that sends tuples containing the previous and current values
    ///            of `self`.
    func combinePrevious() -> Observable<(Element, Element)> {
        var previous: Element?
        return Observable.create { (observer) -> Disposable in
            return self.subscribe { (event) in
                switch event {
                case .next(let element):
                    if let previous = previous {
                        observer.onNext((previous, element))
                    }
                    previous = element
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            }
        }
    }
    
    /// Applies `transform` to values from `self` and forwards values with non-`nil` results
    /// unwrapped.
    ///
    /// - parameters:
    ///   - transform: A closure that accepts a value from the `next` event and returns a new
    ///                optional value.
    /// - returns: A new observable that will send the transformed non-`nil` values.
    func filterMap<R>(transform: @escaping (Element) -> R?) -> Observable<R> {
        return Observable.create { (observer) -> Disposable in
            return self.subscribe { (event) in
                switch event {
                case .next(let element):
                    if let result = transform(element) {
                        observer.onNext(result)
                    }
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            }
        }
    }

    func dejitter(elementsAreDistinct: @escaping (Element, Element) -> Bool) -> Observable<Element> {
        return Observable.create({ (observer) -> Disposable in
            var lastEmitted: Element?
            return self.subscribe({ (event) in
                switch event {
                case .next(let element):
                    if let previous = lastEmitted {
                        if elementsAreDistinct(previous, element) {
                            observer.onNext(element)
                            lastEmitted = element
                        }
                    } else {
                        observer.onNext(element)
                        lastEmitted = element
                    }
                    
                case .error(let error):
                    observer.onError(error)
                    
                case .completed:
                    observer.onCompleted()
                }
            })
        })
    }
    
    // Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
    func mapToVoid() -> Observable<Void> {
        return self.map { _ -> Void in
            return ()
        }
    }
    
    /// Filters out nil values at the objects given keypath and will return the object.
    ///
    /// - Parameter keyPath: The keypath to compare nil values to
    /// - Returns: The base object where the given keypath is non-nil
    func skipNil<T: OptionalProtocol>(keyPath: KeyPath<Element, T> ) -> Observable<Element> {
        return self.filter { $0[keyPath: keyPath].optional != nil }
    }
    
    /// Filters out nil values at the objects given keypath and will map to the value
    /// of the keypath.
    ///
    /// - Parameter keyPath: The keypath to compare nil values to
    /// - Returns: The value at the given keypath
    func skipNilMapResult<T: OptionalProtocol>(keyPath: KeyPath<Element, T> ) -> Observable<T.Wrapped> {
        return self.filterMap { $0[keyPath: keyPath].optional }
    }
}

public extension ObservableType where Element: OptionalProtocol {
    func skipNil() -> Observable<Element.Wrapped> {
        return self.filterMap { $0.optional }
    }
}

public extension BehaviorRelay {
    func modify(modifier: (inout Element) -> Void) {
        var value = self.value
        modifier(&value)
        self.accept(value)
    }
}

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Swift.Never {
    func ignoreError() -> PrimitiveSequence<Trait, Element> {
        return self.catchError { _ in Completable.empty() }
    }
}

public extension Disposable {
    /// This method does nothing. It is a marker that can be used to indicate
    /// when a disposable is intentionally not being added to a bag, in a more
    /// semantically meaningful way than simply assigning it to `_`.
    ///
    /// # Usage:
    ///
    /// Instead of:
    /// ```
    /// _ = observable
    ///     .takeUntil(trigger)
    ///     .subscribe(onNext: { ... })
    /// ```
    /// Try:
    /// ```
    /// observable
    ///     .takeUntil(trigger)
    ///     .subscribe(onNext: { ... })
    ///     .forever()
    /// ```
    func forever() { }
}
