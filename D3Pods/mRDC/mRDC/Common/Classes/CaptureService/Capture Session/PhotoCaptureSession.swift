//
//  PhotoCaptureSession.swift
//  D3 Banking
//
//  Created by Chris Carranza on 2/1/17.
//
//

import Foundation
import AVFoundation
import Logging

// swiftlint:disable weak_delegate
// swiftlint:disable function_parameter_count

// NOTE: The CaptureDelegate class is necessary because the AVCapturePhotoCaptureDelegate protocol also
// requires the NSObject protocol. In order to allow the PhotoCaptureSession class to have a throwing initializer
// and to be pure swift, I chose to create an internal delegate object that is an NSObject subclass to handle the protocol 
// conformance. [CC] 2/2/2017
private final class CaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var captureHandler: ((Data?) -> Void)?
    
    override init() {
        super.init()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        captureHandler?(imageData)
    }
}

final class PhotoCaptureSession: CaptureSession {
    private let session: AVCaptureSession
    private lazy var stillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()

    let previewLayer: AVCaptureVideoPreviewLayer
    
    fileprivate let captureDelegate: CaptureDelegate = CaptureDelegate()
    
    init() throws {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw CaptureSessionError.cameraAccessUnauthorized
        }
        
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInDualCamera],
            mediaType: .video,
            position: .back
        ).devices.first else {
            throw CaptureSessionError.deviceUnavailable
        }

        let cameraInput = try AVCaptureDeviceInput(device: device)
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        self.previewLayer = previewLayer
        
        guard session.canAddInput(cameraInput) else {
            throw CaptureSessionError.invalidDeviceInput
        }
        
        guard session.canAddOutput(stillImageOutput) else {
            throw CaptureSessionError.invalidDeviceOuput
        }
        
        session.addInput(cameraInput)
        session.addOutput(stillImageOutput)
        
        previewLayer.connection?.videoOrientation = (UIDevice.current.userInterfaceIdiom == .pad) ? .portrait : .landscapeRight
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    func startPreview() {
        DispatchQueue.rdc.async {
            self.session.startRunning()
        }
    }
    
    func stopPreview() {
        DispatchQueue.rdc.async {
            self.session.stopRunning()
        }
    }
    
    func captureImage(completion: @escaping (Data?, Error?) -> Void) {
        guard let connection = self.stillImageOutput.connection(with: AVMediaType.video) else {
            completion(nil, CaptureSessionError.deviceUnavailable)

            return
        }
        
        guard stillImageOutput.availablePhotoCodecTypes.contains(AVVideoCodecType.jpeg) else {
            completion(nil, CaptureSessionError.jpegCodecUnavailable)

            return
        }
        
        connection.videoOrientation = .landscapeRight
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])

        self.captureDelegate.captureHandler = { data in
            guard let data = data else {
                completion(nil, CaptureSessionError.invalidImageRepresentation)

                return
            }
            completion(data, nil)
        }

        stillImageOutput.capturePhoto(with: settings, delegate: self.captureDelegate)
    }

    func toggleTorch(on: Bool) {
        DispatchQueue.rdc.async {
            guard let device = AVCaptureDevice.default(for: .video) else { return }

            if device.hasTorch {
                do {
                    try device.lockForConfiguration()

                    if on {
                        device.torchMode = .on
                    } else {
                        device.torchMode = .off
                    }

                    device.unlockForConfiguration()
                } catch {
                    log.error("Lock for torch could not be acquired.")
                }
            }
        }
    }
}
