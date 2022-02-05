//
//  RDCCaptureProvider.swift
//  D3 Banking
//
//  Created by Carlos Paelinck on 6/23/16.
//
//

import AVFoundation
import Localization
import Logging
import UIKit
import Utilities

public typealias CaptureViewController = UIViewController & RDCServiceProtocol

public protocol CaptureViewControllerFactory {
    func create() -> CaptureViewController
    func createToCaptureFront() -> CaptureViewController
    func createToCaptureBack() -> CaptureViewController
}

final class RDCCaptureProvider {
    typealias RDCCaptureProviderCompletionHandler = (RDCCaptureCompletionResult) -> Void
    
    enum RDCCaptureProviderCaptureType {
        case frontAndBack, front, back
    }
    
    enum RDCCaptureCompletionResult {
        case success(_ viewController: CaptureViewController)
        case error(_ errorViewController: UIViewController)
    }

    private let rdcCaptureViewControllerFactory: CaptureViewControllerFactory
    private let cameraRequiredViewControllerFactory: RDCCameraRequiredViewControllerFactory
    private let l10nProvider: L10nProvider
    
    init(l10nProvider: L10nProvider,
         rdcCaptureViewControllerFactory: CaptureViewControllerFactory,
         errorViewControllerFactory: RDCCameraRequiredViewControllerFactory) {
        self.rdcCaptureViewControllerFactory = rdcCaptureViewControllerFactory
        self.l10nProvider = l10nProvider
        self.cameraRequiredViewControllerFactory = errorViewControllerFactory
    }

    func captureViewController(completionHandler: @escaping RDCCaptureProviderCompletionHandler,
                               captureType: RDCCaptureProviderCaptureType) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        // Determine if the user has authorized the camera and proceed or terminate
        // as the permissions allow.
        switch authorizationStatus {
        case .authorized:
            completionHandler(.success(createViewController(forCaptureType: captureType)))
            
        case .denied, .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] permissionGranted in
                
                DispatchQueue.main.async {
                    if permissionGranted {
                        completionHandler(.success(self!.createViewController(forCaptureType: captureType)))
                    } else {
                        completionHandler(.error(self!.cameraRequiredViewControllerFactory.create()))
                    }
                }
            }
        @unknown default:
            log.error("Unknown AVCaptureDevice.authorizationStatus: \(authorizationStatus)")
            fatalError()
        }
    }
    
    private func createViewController(forCaptureType type: RDCCaptureProviderCaptureType) -> CaptureViewController {
        switch type {
        case .front:
            return rdcCaptureViewControllerFactory.createToCaptureFront()
        case .back:
            return rdcCaptureViewControllerFactory.createToCaptureBack()
        case .frontAndBack:
            return rdcCaptureViewControllerFactory.create()
        }
    }
}
