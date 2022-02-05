//
//  WebComponentPath.swift
//  Web
//
//  Created by Andrew Watt on 7/2/18.
//

import Foundation

public struct WebComponentPath: Equatable {
    /// The exact path to the web component to be used in the
    /// web view.
    public var path: String
    public var showsUserProfile: Bool

    public init(path: String, showsUserProfile: Bool = false) {
        self.path = path
        self.showsUserProfile = showsUserProfile
    }
}
