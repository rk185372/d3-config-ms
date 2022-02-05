//
//  RDCCaptureModule.swift
//  mRDC
//
//  Created by Branden Smith on 2/18/19.
//

import DependencyContainerExtension
import Dip
import Foundation

final class RDCCaptureModule: DependencyContainerModule {
    static func provideDependencies(to container: DependencyContainer) {
        container.register {
            MiSnapCaptureViewControllerFactory(
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve()
            ) as CaptureViewControllerFactory
        }
    }
}
