//
//  CaptureSession.swift
//  D3 Banking
//
//  Created by Chris Carranza on 2/1/17.
//
//

import Foundation
import AVFoundation

enum CaptureSessionError: Error {
    case cameraAccessUnauthorized
    case deviceUnavailable
    case invalidDeviceInput
    case invalidDeviceOuput
    case invalidImageRepresentation
    case jpegCodecUnavailable
}

protocol CaptureSession {
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    
    init() throws
    func startPreview()
    func stopPreview()
    func captureImage(completion: @escaping (Data?, Error?) -> Void)
    func toggleTorch(on: Bool)
}
