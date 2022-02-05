//
//  RDCStandardViewController.swift
//
//  Created by Carlos Paelinck on 6/27/16.
//  Copyright © 2016 D3 Banking. All rights reserved.
//

import UIKit
import AVFoundation
import Utilities
import ComponentKit
import Localization
import Logging

enum RDCStandardViewControllerError: Error {
    case invalidImageRepresentation
    case missingImageData
}

public final class RDCStandardCaptureViewController: UIViewControllerComponent {
    
    public enum RDCCaptureType {
        case front, back, both
    }
    
    private enum RDCCaptureSide {
        case front
        case back
    }
    
    @IBOutlet weak var topLabel: UILabelComponent!
    @IBOutlet weak var bottomLabel: UILabelComponent!
    @IBOutlet weak var rotationAlertLabel: UILabelComponent!

    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    @IBOutlet weak var viewPortView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var backGuidesView: UIView!
    @IBOutlet weak var flashView: UIView!
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var captureButton: RDCCaptureButton!
    @IBOutlet weak var useButton: UIButtonComponent!
    @IBOutlet weak var retakeButton: UIButtonComponent!
    @IBOutlet weak var closeButton: UIButtonComponent!
    
    private var captureSession: CaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var blurEffectView: UIView!
    
    private var captureSide: RDCCaptureSide = .front
    private let captureType: RDCCaptureType
    private var frontImage: Data?
    private var backImage: Data?
    private var sessionIsEstablished: Bool = false
    private var torchIsOn: Bool = false
    
    var completionHandler: RDCCaptureCompletionHandler?
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                completionHandler: RDCCaptureCompletionHandler? = nil,
                captureType: RDCCaptureType = .both) {
        self.completionHandler = completionHandler
        self.captureType = captureType
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "RDCStandardCaptureViewController",
            bundle: StandardRDCBundle.bundle
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        switch captureType {
        case .back:
            setupCaptureBackUI()
            captureSide = .back
        default:
            setupCaptureFrontUI()
        }
        
        setupUsePhotoButton()
        setupCapturePhotoButton()
        setupRetakePhotoButton()
        setupTorchButton()
        setupCloseButton()
        
        accessibilityElements = [
            topLabel as Any,
            torchButton as Any,
            closeButton as Any,
            bottomLabel as Any,
            captureButton as Any
        ]
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !sessionIsEstablished {
            establishSession()
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            setupIpadRotationAlert(orientCamera: true)
        } else {
            rotationAlertLabel.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            UIAccessibility.post(notification: .screenChanged, argument: self.topLabel)
        }
    }

    public override var shouldAutorotate: Bool {
        return false
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let orientation = UIDevice.current.orientation
        let rotatedFrame = CGRect(
            x: 0,
            y: 0,
            width: self.view.window!.frame.size.height,
            height: self.view.window!.frame.size.width
        )

        switch orientation {
        case .portrait:
            previewLayer.frame = rotatedFrame
            previewLayer.connection?.videoOrientation = .portrait
            blurEffectView.fadeIn()
        case .portraitUpsideDown:
            previewLayer.frame = rotatedFrame
            previewLayer.connection?.videoOrientation = .portraitUpsideDown
            blurEffectView.fadeIn()
        case .landscapeLeft:
            previewLayer.frame = rotatedFrame
            previewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeLeft
            previewLayer.frame = rotatedFrame
        case .faceUp, .faceDown, .unknown:
            log.error("Unsued Orientation being used in RDCStandardCaptureViewController")
        @unknown default:
            log.error("Brand New Orientation being used in RDCStandardCaptureViewController")
        }

        self.visualEffectsView.isHidden = true

        coordinator.animate(alongsideTransition: nil) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.visualEffectsView.isHidden = false
                self.setPreviewLayer()
                self.setupIpadRotationAlert(orientCamera: false)
            }
        }
    }

    private func setupIpadRotationAlert(orientCamera: Bool = false) {
        let orientation = UIDevice.current.orientation
        if orientCamera {
            switch orientation {
            case .portrait:
                previewLayer.connection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                previewLayer.connection?.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                previewLayer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight:
                previewLayer.connection?.videoOrientation = .landscapeLeft
            case .faceUp, .faceDown, .unknown:
                log.error("Unusued Orientation being used in RDCStandardCaptureViewController")
            @unknown default:
                log.error("Brand New Orientation being used in RDCStandardCaptureViewController")
            }
        }

        if (blurEffectView == nil) {
            let blurEffect: UIBlurEffect = UIBlurEffect(style: .regular)
            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.blurEffectView.frame = self.rotationAlertLabel.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView)
        }

        if orientation == .landscapeLeft ||
            orientation == .landscapeRight {
            rotationAlertLabel.fadeOut()
            blurEffectView.fadeOut()
            captureButton.isEnabled = true
        } else {
            self.view.bringSubviewToFront(rotationAlertLabel)
            rotationAlertLabel.backgroundColor = .clear
            rotationAlertLabel.fadeIn()
            rotationAlertLabel.text = l10nProvider.localize("device.rdc.rotate.label")
            rotationAlertLabel.textColor = .white
            captureButton.isEnabled = false
        }
    }
    
    private func setupUsePhotoButton() {
        useButton.setTitle(l10nProvider.localize("device.rdc.use.btn"), for: .normal)
        useButton.titleLabel?.textAlignment = .center
    }

    private func setupCapturePhotoButton() {
        captureButton.accessibilityLabel = l10nProvider.localize("device.rdc.capture.capturePhoto.btn.altText")
    }
    
    private func setupRetakePhotoButton() {
        retakeButton.setTitle(l10nProvider.localize("device.rdc.retake.btn"), for: .normal)
        retakeButton.titleLabel?.textAlignment = .center
    }

    private func setupTorchButton() {
        torchButton.setTitle(nil, for: .normal)

        torchButton.setImage(
            torchIsOn
                ? UIImage(named: "FlashOn", in: StandardRDCBundle.bundle, compatibleWith: nil)!
                : UIImage(named: "FlashOff", in: StandardRDCBundle.bundle, compatibleWith: nil)!,
            for: .normal
        )

        torchButton.accessibilityLabel = torchIsOn
            ? l10nProvider.localize("device.rdc.capture.flash.btn.flashOn.altText")
            : l10nProvider.localize("device.rdc.capture.flash.btn.flashOff.altText")

        torchButton.accessibilityHint = torchIsOn
            ? l10nProvider.localize("device.rdc.capture.flash.btn.flashOn.hint.altText")
            : l10nProvider.localize("device.rdc.capture.flash.btn.flashOff.hint.altText")
    }

    private func setupCloseButton() {
        closeButton.accessibilityLabel = l10nProvider.localize("device.rdc.close.btn.altText")
    }
    
    private func setupCaptureFrontUI() {
        topLabel.text = l10nProvider.localize("device.rdc.front-of-check")
        bottomLabel.text = l10nProvider.localize("device.rdc.front.info")
    }
    
    private func setupCaptureBackUI() {
        topLabel.text = l10nProvider.localize("device.rdc.back-of-check")
        bottomLabel.text = l10nProvider.localize("device.rdc.back.info")
    }
    
    private func establishSession() {
        do {
            captureSession = try PhotoCaptureSession()
            
            try startPreview()
        } catch {
            displayStandardError(error)
        }
        
        sessionIsEstablished = true
    }
    
    private func startPreview() throws {
        setPreviewLayer()
        setToCaptureMode()
    }
    
    func setPreviewLayer() {
        previewLayer = captureSession.previewLayer
        previewLayer.frame = self.view.layer.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // Setup viewport cutout
        let path = UIBezierPath(rect: self.view.frame)
        path.append(UIBezierPath(rect: self.viewPortView.frame).reversing())
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        
        visualEffectsView.layer.mask = shapeLayer
    }
    
    private func setToCaptureMode() {
        previewImage.isHidden = true
        useButton.isHidden = true
        retakeButton.isHidden = true
        captureButton.isHidden = false
        closeButton.isHidden = false
        bottomLabel.isHidden = false
        
        captureSession.startPreview()
        captureSession.toggleTorch(on: torchIsOn)
    }
    
    private func setToPreviewMode(data: Data) {
        previewImage.isHidden = false
        useButton.isHidden = false
        retakeButton.isHidden = false
        captureButton.isHidden = true
        closeButton.isHidden = true
        bottomLabel.isHidden = true
        
        captureSession.stopPreview()
        
        previewImage.image = UIImage(data: data)

        UIAccessibility.post(notification: .layoutChanged, argument: useButton)
    }
    
    private func flipView(animations: @escaping () -> Void) {
        UIView.transition(
            with: view,
            duration: 0.75,
            options: UIView.AnimationOptions.transitionFlipFromBottom,
            animations: animations,
            completion: nil
        )
    }
    
    private func flash() {
        flashView.isHidden = false
        flashView.alpha = 0
        
        // Using CABasicAnimation to autoreverse
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.1
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = 0
        animation.toValue = 1
        flashView.layer.add(animation, forKey: "animateOpacity")
    }
    
    private func cropArea(from imageData: Data, for viewOfInterest: UIView, completion: @escaping (Data?, Error?) -> Void) {
        guard let origImage = UIImage(data: imageData) else {
            completion(nil, RDCStandardViewControllerError.missingImageData)
            return
        }
        var rotatedImage: UIImage!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait:
                rotatedImage = origImage.rotate(radians: .pi / 2)
            case .portraitUpsideDown:
                rotatedImage = origImage.rotate(radians: -(.pi / 2))
            case .landscapeLeft:
                rotatedImage = origImage.rotate(radians: 0)
            case .landscapeRight:
                rotatedImage = origImage.rotate(radians: .pi)
            case .faceUp:
                rotatedImage = origImage.rotate(radians: 0)
            case .faceDown:
                log.error("Facedown Orientation being used in RDCStandardCaptureViewController")
            case .unknown:
                log.error("Unknown Orientation being used in RDCStandardCaptureViewController")
            @unknown default:
                log.error("Brand New Orientation being used in RDCStandardCaptureViewController")
            }
            
            let cropped = croppedCGI(viewOfInterest: viewOfInterest.frame, image: rotatedImage)
            
            //resize / compress
            guard let scaledImageData = UIImage(cgImage: cropped).resizedImageForRDC().jpegRepresentationForRDC()  else {
                completion(nil, RDCStandardViewControllerError.invalidImageRepresentation)
                return
            }
            
            completion(scaledImageData, nil)
            
        } else {
            
            let cropped = croppedCGI(viewOfInterest: viewOfInterest.frame, image: origImage)
            
            //resize / compress
            guard let scaledImageData = UIImage(cgImage: cropped).resizedImageForRDC().jpegRepresentationForRDC()  else {
                completion(nil, RDCStandardViewControllerError.invalidImageRepresentation)
                return
            }
            
            completion(scaledImageData, nil)
        }
    }
    
    private func croppedCGI(viewOfInterest: CGRect, image: UIImage) -> CGImage {
        let output = captureSession.previewLayer.metadataOutputRectConverted(fromLayerRect: viewOfInterest)
        let croppingRect = CGRect(
            x: output.origin.x * image.size.width,
            y: output.origin.y * image.size.height,
            width: output.size.width * image.size.width,
            height: output.size.height * image.size.height
        )
        return image.cgImage!.cropping(to: croppingRect)!
    }
    
    private func displayStandardError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "An error has occurred (\(error))",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
            self?.cancelCapture()
        }))

        present(alert, animated: true, completion: nil)
    }
    
    private func cancelCapture() {
        completionHandler?(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func finishImageCapture() {
        self.captureButton.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions

    @IBAction func torchButtonTouched(_ sender: UIButton) {
        torchIsOn.toggle()
        captureSession.toggleTorch(on: torchIsOn)
        setupTorchButton()
    }
    
    @IBAction func captureButtonPressed(_ sender: Any) {
        captureButton.isUserInteractionEnabled = false
        
        flash()

        captureSession.captureImage { [weak self] (data, error) in
            guard let data = data, let viewPort = self?.viewPortView else {
                if let err = error { self?.displayStandardError(err) }
                self?.finishImageCapture()
                return
            }
            
            self?.cropArea(from: data, for: viewPort, completion: { (croppedData, error) in
                guard let data = croppedData else {
                    if let err = error { self?.displayStandardError(err) }
                    self?.finishImageCapture()
                    return
                }
                
                self?.setToPreviewMode(data: data)
                
                if self?.captureSide == .front {
                    self?.frontImage = data
                } else {
                    self?.backImage = data
                }
                
                self?.finishImageCapture()
            })
        }
    }
    
    @IBAction func useButtonPressed(_ sender: UIButton) {
        if captureSide == .front, captureType == .both {
            captureSide = .back
            setToCaptureMode()
            flipView { [weak self] in
                // Set to "back of check" view properties
                self?.setupCaptureBackUI()
                self?.backGuidesView.isHidden = false
                UIAccessibility.post(notification: .layoutChanged, argument: self?.topLabel)
            }
        } else {            
            completionHandler?(RDCCaptureImages(front: frontImage ?? Data(),
                                                back: backImage ?? Data(),
                                                origFront: nil,
                                                origBack: nil))
        }
    }
    
    @IBAction func retakeButtonPressed(_ sender: UIButton) {
        setToCaptureMode()
        UIAccessibility.post(notification: .layoutChanged, argument: self.topLabel)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        cancelCapture()
    }
}

extension RDCStandardCaptureViewController: RDCServiceProtocol {
    public func setCaptureCompletion(completion: @escaping (RDCCaptureImages?) -> Void) {
        self.completionHandler = completion
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval? = 0.2, withAlpha: CGFloat? = 1, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(
            withDuration: duration!,
            animations: { self.alpha = withAlpha! },
            completion: { _ in
                if let complete = onCompletion { complete() }
            }
        )
    }

    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration!,
            animations: { self.alpha = 0 },
            completion: { _ in
                self.isHidden = true
                if let complete = onCompletion { complete() }
            }
        )
    }
}
