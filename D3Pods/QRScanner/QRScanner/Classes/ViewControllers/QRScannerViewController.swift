//
//  QRScannerViewController.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 20/12/2021.
//

import UIKit
import AVFoundation
import Localization

public protocol QRScannerViewControllerDelegate: AnyObject {
    associatedtype DataModel
    func didScanQRCode(withData data: DataModel)
    func didFailScanningQRCode(withError error: Error?)
}

public enum ProfileQRCodeInfoValidatorError: Error {
    case invalid(title: String, description: String)
}

public protocol ProfileQRCodeInfoBuilder {
    associatedtype DataModel
    func isValid(_ info: String) -> ProfileQRCodeInfoValidatorError?
    func buildInfo(from model: DataModel) -> String?
    func decodeInfo(_ info: String) -> DataModel?
}

public struct ProfileQRCodeDataModel<QRDataModel> {
    public let userId: String
    public let username: String
    public let userPic: UIImage?
    public let qrData: QRDataModel
    
    public init(userId: String,
                username: String,
                userPic: UIImage?,
                qrData: QRDataModel) {
        self.userId = userId
        self.username = username
        self.userPic = userPic
        self.qrData = qrData
    }
}

public enum QRScannerViewControllerMode {
    case scan, view
}

public struct QRScannerViewControllerModel<ValidatorType: ProfileQRCodeInfoBuilder> {
    let profilesData: [ProfileQRCodeDataModel<ValidatorType.DataModel>]
    let validator: ValidatorType
    let mode: QRScannerViewControllerMode
    
    public init(profilesData: [ProfileQRCodeDataModel<ValidatorType.DataModel>],
                validator: ValidatorType,
                mode: QRScannerViewControllerMode) {
        self.profilesData = profilesData
        self.validator = validator
        self.mode = mode
    }
}

private struct SegmentIndex {
    static let scanQR = 0
    static let myQR = 1
}

public class QRScannerViewController< ValidatorType: ProfileQRCodeInfoBuilder,
                                      DelegateType: QRScannerViewControllerDelegate >: UIViewController,
                                                                                       AVCaptureMetadataOutputObjectsDelegate,
                                                                                       UICollectionViewDelegate,
                                                                                       UICollectionViewDataSource,
                                                                                       UIImagePickerControllerDelegate,
                                                                                       UINavigationControllerDelegate
where ValidatorType.DataModel == DelegateType.DataModel {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var scanFrameView: UIView!
    @IBOutlet weak var myCodeView: UIView!
    @IBOutlet weak var profilesQRCollectionView: UICollectionView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var pickerController: UIImagePickerController!
    private var errorView: QRScanErrorView!
    
    private let model: QRScannerViewControllerModel<ValidatorType>
    private let utils: QRCodeUtils
    private let l10nProvider: L10nProvider
    private var profileCellModels: [ProfileQRCodeCellModel] = []
    
    private weak var delegate: DelegateType?
    
    private var flowLayout: UICollectionViewFlowLayout!
    private var currentPageOffset: CGFloat = 0
    
    public init(model: QRScannerViewControllerModel<ValidatorType>,
                utils: QRCodeUtils,
                l10nProvider: L10nProvider,
                delegate: DelegateType? = nil) {
        self.model = model
        self.utils = utils
        self.l10nProvider = l10nProvider
        super.init(nibName: "QRScannerViewController", bundle: QRScannerBundle.bundle)
        self.profileCellModels = model.profilesData.map {
            let qrImage = utils.generateQRCode(from: model.validator.buildInfo(from: $0.qrData) ?? "")
            let shareDescription = "\($0.username)"
            return ProfileQRCodeCellModel(profilePic: $0.userPic,
                                          username: $0.username,
                                          userId: $0.userId,
                                          qrImage: qrImage,
                                          shareAction: { [weak self] in
                self?.showShareSheet(for: qrImage!, withDescription: shareDescription)
            })
        }
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.setTitle(l10nProvider.localize("qr.tab.scan"), forSegmentAt: 0)
        segmentControl.setTitle(l10nProvider.localize("qr.tab.myCode"), forSegmentAt: 1)
        
        setupQRScannerView()
        setupMyQRView()
        
        segmentControl.selectedSegmentIndex = model.mode == .scan ? SegmentIndex.scanQR : SegmentIndex.myQR
        segmentControl.isHidden = model.mode == .view
        segmentControl.addTarget(self, action: #selector(updateUI), for: .valueChanged)
        updateUI()
        
        errorView = QRScanErrorView()
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.makeMatch(view: view)
        errorView.isHidden = true
    }
    
    private func setupQRScannerView() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        scanView.layer.insertSublayer(previewLayer, below: scanFrameView.layer)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if segmentControl.selectedSegmentIndex == SegmentIndex.scanQR {
            captureSession.startRunning()
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }
    
    private func setupMyQRView() {
        profilesQRCollectionView.register(UINib(nibName: "ProfileQRCodeCell", bundle: QRScannerBundle.bundle),
                                          forCellWithReuseIdentifier: "profileQRCell")
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        profilesQRCollectionView.collectionViewLayout = flowLayout
        
        profilesQRCollectionView.delegate = self
        profilesQRCollectionView.dataSource = self
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // QR Scanner Perview layer
        let framePadding: CGFloat = 32.0
        previewLayer?.frame = CGRect(x: scanFrameView.frame.minX - framePadding,
                                     y: scanFrameView.frame.minY - framePadding,
                                     width: scanFrameView.bounds.width + 2 * framePadding,
                                     height: scanFrameView.bounds.height + 2 * framePadding)
        // Profile QR items
        flowLayout.itemSize = CGSize(width: profilesQRCollectionView.bounds.width - 80,
                                     height: profilesQRCollectionView.bounds.height - 32)
    }
    
    private var isScanning: Bool {
        return captureSession.isRunning == true
    }
    
    private func startScanning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
            previewLayer?.isHidden = false
        }
    }
    
    private func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            previewLayer?.isHidden = true
        }
    }
    
    private func failed() {
        let msg = "Your device does not support scanning a code from an item. Please use a device with a camera."
        let ac = UIAlertController(title: "Scanning not supported",
                                   message: msg,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(ac, animated: true)
        captureSession = nil
    }
    
    @objc private func updateUI() {
        switch segmentControl.selectedSegmentIndex {
        case SegmentIndex.scanQR:
            scanView.isHidden = false
            myCodeView.isHidden = true
            startScanning()
        default:
            scanView.isHidden = true
            myCodeView.isHidden = false
            stopScanning()
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let error = model.validator.isValid(stringValue) {
                self.showErrorView(for: error)
            } else {
                delegate?.didScanQRCode(withData: model.validator.decodeInfo(stringValue)!)
            }
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction private func showImagePicker() {
        pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image"]
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    private func showShareSheet(for qrImage: UIImage, withDescription description: String) {
        // If you want to use an image
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [description, qrImage], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.completionWithItemsHandler = {[weak self] activity, completed, items, error in
            guard let activity = activity, let self = self else { return }
            switch activity {
            case .saveToCameraRoll:
                let toSave = UIImage(cgImage: CIContext(options: nil).createCGImage(qrImage.ciImage!, from: qrImage.ciImage!.extent)!)
                UIImageWriteToSavedPhotosAlbum(toSave, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            default:
                break
            }
        }
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "QR image could not be saved!", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func showErrorView(for error: ProfileQRCodeInfoValidatorError) {
        switch error {
        case .invalid(let title, let description):
            stopScanning()
            errorView.configure(withTitle: title,
                                description: description,
                                retryAction: { [weak self] in
                guard let self = self else { return }
                self.hideErrorView()
                self.startScanning()
            }, cancelAction: { [weak self] in
                guard let self = self else { return }
                self.hideErrorView()
                self.delegate?.didFailScanningQRCode(withError: error)
            })
            errorView.isHidden = false
        }
    }
    
    private func hideErrorView() {
        errorView.isHidden = true
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileCellModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileQRCell", for: indexPath)
                as? ProfileQRCodeCell else {
                    fatalError("Could mot dequeue cell for ProfileQRCodeCell")
                }
        cell.configure(with: profileCellModels[indexPath.row])
        return cell
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
        let targetPage = CGFloat(Int((targetContentOffset.pointee.x + flowLayout.minimumInteritemSpacing) / pageWidth))
        let currentPage = CGFloat(Int((scrollView.contentOffset.x + flowLayout.minimumInteritemSpacing) / pageWidth))
        let inPageOffset = (scrollView.contentOffset.x - (currentPage * pageWidth)) / pageWidth
        let delta = targetContentOffset.pointee.x - currentPageOffset
        var targetX = currentPageOffset
        if delta < 0, velocity.x < -0.1 || inPageOffset < 0.9 {
            targetX = targetPage * pageWidth
        } else if 0 < delta, 0.1 < velocity.x || 0.1 < inPageOffset {
            targetX = (targetPage + 1) * pageWidth
        }
        targetContentOffset.pointee.x = targetX
        currentPageOffset = targetX
    }
    
    // MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let qrcodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let info = self.utils.string(fromQRCodeImage: qrcodeImg)
                if let error = self.model.validator.isValid(info) {
                    self.showErrorView(for: error)
                } else {
                    self.delegate?.didScanQRCode(withData: self.model.validator.decodeInfo(info)!)
                }
            }
        }
    }
}
