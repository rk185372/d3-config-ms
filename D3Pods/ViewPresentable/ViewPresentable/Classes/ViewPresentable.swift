//
//  ViewPresentable.swift
//  Authentication
//
//  Created by Chris Carranza on 6/14/18.
//

import Foundation

public protocol ViewPresentable: Equatable {
    associatedtype View: UIView
    
    func createView() -> View
    func configure(view: View)
}

/// Used internally to `erase` the type used with ViewPresentable
private protocol _AnyViewPresentableBox {
    var _base: Any { get }
    func _createView() -> UIView
    func _configure(view: UIView)
    func _unbox<T: ViewPresentable>() -> T?
    func _isEqual(to: _AnyViewPresentableBox) -> Bool?
}

private struct _ConcreteViewPresentableBox<Base: ViewPresentable>: _AnyViewPresentableBox {
    private var _baseChallengeItemPresentable: Base
    
    public init(_ base: Base) {
        self._baseChallengeItemPresentable = base
    }
    
    internal func _unbox<T: ViewPresentable>() -> T? {
        return (self as _AnyViewPresentableBox as? _ConcreteViewPresentableBox<T>)?._baseChallengeItemPresentable
    }
    
    internal func _isEqual(to rhs: _AnyViewPresentableBox) -> Bool? {
        if let rhs: Base = rhs._unbox() {
            return _baseChallengeItemPresentable == rhs
        }
        
        return nil
    }
    
    public var _base: Any {
        return _baseChallengeItemPresentable
    }
    
    func _createView() -> UIView {
        return _baseChallengeItemPresentable.createView()
    }

    public func _configure(view: UIView) {
        _baseChallengeItemPresentable.configure(view: view as! Base.View)
    }
}

/// A type-erased ViewPresentable value.
///
/// This allows for the storage of mixed type UIView values in collections
/// that require `ViewPresentable` conformance by wrapping mixed view type objects
/// in AnyViewPresentable instances.
public struct AnyViewPresentable {
    private var _box: _AnyViewPresentableBox
    
    public init<P: ViewPresentable>(_ base: P) {
        self._box = _ConcreteViewPresentableBox(base)
    }
    
    public var base: Any {
        return _box._base
    }
}

extension AnyViewPresentable: ViewPresentable {
public func createView() -> UIView {
        return _box._createView()
    }
    
    public func configure(view: UIView) {
        _box._configure(view: view)
    }
}

extension AnyViewPresentable: Equatable {
    public static func == (lhs: AnyViewPresentable, rhs: AnyViewPresentable) -> Bool {
        if let result = lhs._box._isEqual(to: rhs._box) { return result }
        
        return false
    }
}
