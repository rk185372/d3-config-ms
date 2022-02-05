//
//  CancelableBag.swift
//  Utilities
//
//  Created by Andrew Watt on 10/17/18.
//

import Foundation
import RxSwift

/// `DisposeBag` wrapper that also allows explicit disposal.
public final class CancelableBag {
    private var bag = DisposeBag()
    
    public init() { }
    
    public func insert(_ disposable: Disposable) {
        bag.insert(disposable)
    }
    
    public func insert(action: @escaping () -> Void) {
        bag.insert(Disposables.create(with: action))
    }
    
    /// Dispose all items in this bag and empty the bag.
    public func cancel() {
        bag = DisposeBag()
    }
}

public extension Disposable {
    func disposed(by bag: CancelableBag) {
        bag.insert(self)
    }
}
