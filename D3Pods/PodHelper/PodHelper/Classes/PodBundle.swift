//
//  PodBundle.swift
//  Pods
//
//  Created by Chris Carranza on 7/26/17.
//

import Foundation

/// Used to simplify the process of accessing a pods bundle when using "s.bundle_resources" in a podspec
public protocol PodBundle: class {
    
    /// The bundle identifier specified in the "s.bundle_resources" property of your podspec
    static var bundleIdentifier: String { get }
}

extension PodBundle {
    /// The pods bundle using the bundleIdentifier
    public static var bundle: Bundle {
        let podBundle = Bundle(for: Self.self)
        
        guard let bundleUrl = podBundle.url(forResource: Self.bundleIdentifier, withExtension: "bundle"),
            let bundle = Bundle(url: bundleUrl) else {
                fatalError("Error: could not find resource of type `bundle` with name `\(Self.bundleIdentifier)`")
        }
        
        return bundle
    }
    
    /// Retrieves a storyboard from the pod bundle
    ///
    /// - Parameter name: storyboard name
    /// - Returns: a UIStoryboard
    public static func storyboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: Self.bundle)
    }
    
    /// Retrieves a nib from the pod bundle
    ///
    /// - Parameter name: nib name
    /// - Returns: a UINib
    public static func nib(name: String) -> UINib {
        return UINib(nibName: name, bundle: Self.bundle)
    }
    
    /// Retrieves an image from the pod bundle
    ///
    /// - Parameter named: image name
    /// - Returns: an UIIMage
    public static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Self.bundle, compatibleWith: nil)
    }
}
