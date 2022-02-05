//
//  BuildInfoViewControllerFactory.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 12/14/18.
//

import ComponentKit
import Foundation
import Localization
import Utilities

public final class BuildInfoViewControllerFactory: ViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let themeService: ThemeService
    private let l10nService: L10nService
    private let buildInfoScreenState: BuildInfoScreenState

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                themeService: ThemeService,
                l10nService: L10nService,
                buildInfoScreenState: BuildInfoScreenState) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.themeService = themeService
        self.l10nService = l10nService
        self.buildInfoScreenState = buildInfoScreenState
    }

    public func create() -> UIViewController {
        return BuildInfoViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            themeService: themeService,
            l10nService: l10nService,
            buildInfoScreenState: buildInfoScreenState
        )
    }
}
