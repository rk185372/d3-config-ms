//
//  ExternalWebViewNavigationConfig.swift
//  ComponentKit
//
//  Created by Elvin Bearden on 7/20/20.
//

import Foundation

public struct ExternalWebViewNavigationConfig: Decodable {
    /// When set to `true`, shows the back and forward navigation buttons, else they are hidden
    let navigable: Bool

    /// When set to `true`, shows the refresh button, else it is hidden
    let refreshable: Bool

    /// When set to `true`, shows the share button, else it is hidden
    let shareable: Bool

    public init(navigable: Bool, refreshable: Bool = true, shareable: Bool = false) {
        self.navigable = navigable
        self.refreshable = refreshable
        self.shareable = shareable
    }

    public init(configuration: [String: Any]) throws {
        self = try JSONDecoder().decode(
            ExternalWebViewNavigationConfig.self,
            from: JSONSerialization.data(withJSONObject: configuration)
        )
    }
}
