//
//  ComponentStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 4/24/18.
//

import Foundation

/// A protocol for an object to style a given UI Component
public protocol ComponentStyle: Equatable {
    associatedtype Component
    func style(component: Component)
}

// MARK: - AnyComponentStyle
//https://github.com/apple/swift/blob/master/stdlib/public/core/AnyHashable.swift

extension ComponentStyle {
    /// Wraps ComponentStyle into a type-erased AnyComponentStyle
    ///
    /// - Returns: AnyComponentStyle
    public func anyComponentStyle() -> AnyComponentStyle {
        return self is AnyComponentStyle ? self as! AnyComponentStyle : AnyComponentStyle(self)
    }
}

/// Used internally to `erase` the type used with ComponentStyle
internal protocol _AnyComponentStyleBox {
    var _base: Any { get }
    func _style(component: Any)
    func _unbox<T: ComponentStyle>() -> T?
    func _isEqual(to: _AnyComponentStyleBox) -> Bool?
}

internal struct _ConcreteAnyComponentStyleBox<Base: ComponentStyle>: _AnyComponentStyleBox {
    private var _baseComponentStyle: Base
    
    public init(_ base: Base) {
        self._baseComponentStyle = base
    }
    
    internal func _unbox<T: ComponentStyle>() -> T? {
        return (self as _AnyComponentStyleBox as? _ConcreteAnyComponentStyleBox<T>)?._baseComponentStyle
    }
    
    internal func _isEqual(to rhs: _AnyComponentStyleBox) -> Bool? {
        if let rhs: Base = rhs._unbox() {
            return _baseComponentStyle == rhs
        }
        
        return nil
    }
    
    public var _base: Any {
        return _baseComponentStyle
    }
    
    public func _style(component: Any) {
        _baseComponentStyle.style(component: component as! Base.Component)
    }
}

/// A type-erased ComponentStyle value.
///
/// This allows for the storage of mixed type ComponentStyle values in collections
/// that require `ComponentStyle` conformance by wrapping mixed type objects
/// in AnyComponentStyle instances.
public struct AnyComponentStyle {
    internal var _box: _AnyComponentStyleBox
    
    public init<S: ComponentStyle>(_ base: S) {
        self._box = _ConcreteAnyComponentStyleBox(base)
    }
    
    public var base: Any {
        return _box._base
    }
}

extension AnyComponentStyle: ComponentStyle {
    public func style(component: Any) {
        _box._style(component: component)
    }
}

extension AnyComponentStyle: Equatable {
    public static func == (lhs: AnyComponentStyle, rhs: AnyComponentStyle) -> Bool {
        if let result = lhs._box._isEqual(to: rhs._box) { return result }
        
        return false
    }
}
