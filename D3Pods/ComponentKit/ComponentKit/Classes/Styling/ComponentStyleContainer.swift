//
//  ComponentStyleContainer.swift
//  ComponentKit
//
//  Created by Chris Carranza on 4/25/18.
//

import Foundation

/// Defines the requirements for a container to hold ComponentStyles
public protocol ComponentStyleProvider {
    /// Load a given style into the container with the specified identifier
    ///
    /// - Parameters:
    ///   - style: A ComponentSyle to store
    ///   - identifier: A String identifier by which the style can be retreived
    func load<S: ComponentStyle>(style: S, forIdentifier identifier: String)
    
    /// Returns a ComponentStyle for the given identifier
    ///
    /// - Parameter identifier: The identifier of the style
    /// - Returns: A ComponentStyle
    func componentStyle<S: ComponentStyle>(forIdentifier identifier: String) -> S
    
    subscript<S: ComponentStyle>(identifier: String) -> S { get set }
    subscript<S: ComponentStyle, I: RawRepresentable>(identifier: I) -> S where I.RawValue == String { get set }
}

/// A container to hold ComponentStyles
public final class ComponentStyleContainer: ComponentStyleProvider {
    
    private var styles: [String: AnyComponentStyle] = [:]
    
    public init() {}
    
    public func load<S: ComponentStyle>(style: S, forIdentifier identifier: String) {
        styles[identifier] = style.anyComponentStyle()
    }
    
    public func componentStyle<S: ComponentStyle>(forIdentifier identifier: String) -> S {
        guard let style = styles[identifier] else {
            fatalError("Missing style with identifier: \(identifier)")
        }
        
        // This covers the case where the type requested is AnyComponentStyle
        // instead of a more strongly typed ComponentStyle
        if S.self is AnyComponentStyle.Type {
            return style as! S
        }
        
        guard style.base is S else {
            fatalError("Invalid style type: \(String(describing: type(of: style)))")
        }
        
        return style.base as! S
    }
}

extension ComponentStyleContainer {
    public subscript<S: ComponentStyle>(identifier: String) -> S {
        get {
            return componentStyle(forIdentifier: identifier)
        }
        set {
            load(style: newValue, forIdentifier: identifier)
        }
    }
    
    public subscript<S: ComponentStyle, I: RawRepresentable>(identifier: I) -> S where I.RawValue == String {
        get {
            return componentStyle(forIdentifier: identifier.rawValue)
        }
        set {
            load(style: newValue, forIdentifier: identifier.rawValue)
        }
    }
}
