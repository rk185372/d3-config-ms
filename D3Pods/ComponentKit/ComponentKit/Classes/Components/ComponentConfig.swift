//
//  ComponentConfig.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/9/18.
//

import Foundation
import Localization

public struct ComponentConfig {
    public var l10nProvider: L10nProvider
    public var componentStyleProvider: ComponentStyleProvider
    
    public init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
		self.l10nProvider = l10nProvider
		self.componentStyleProvider = componentStyleProvider
    }
}
