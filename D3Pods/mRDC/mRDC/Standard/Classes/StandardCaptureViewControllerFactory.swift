//
//  StandardCaptureViewControllerFactory.swift
//  Pods
//
//  Created by Chris Carranza on 6/10/19.
//

import Foundation
import Localization
import ComponentKit

public final class StandardCaptureViewControllerFactory: CaptureViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
    }
    
    public func create() -> CaptureViewController {
        return create(captureType: .both)
    }
    
    public func createToCaptureFront() -> CaptureViewController {
        return create(captureType: .front)
    }
    
    public func createToCaptureBack() -> CaptureViewController {
        return create(captureType: .back)
    }
    
    private func create(captureType: RDCStandardCaptureViewController.RDCCaptureType) -> CaptureViewController {
        return RDCStandardCaptureViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            captureType: captureType
        ) as CaptureViewController
    }
}
