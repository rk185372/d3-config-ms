//
//  LazyPostAuthStep.swift
//  PostAuthFlowController
//
//  Created by Andrew Watt on 8/23/18.
//

import UIKit

public final class LazyPostAuthStep: PostAuthStep {
    public typealias Factory = () -> UIViewController
    
    private var iterator: AnyIterator<Factory>
    
    public convenience init(_ factories: Factory...) {
        self.init(iterator: factories.makeIterator())
    }
    
    public init<T>(iterator: T) where T: IteratorProtocol, T.Element == Factory {
        self.iterator = AnyIterator(iterator)
    }
    
    public func viewControllers() -> AnyIterator<UIViewController> {
        return AnyIterator { self.iterator.next()?() }
    }
}
