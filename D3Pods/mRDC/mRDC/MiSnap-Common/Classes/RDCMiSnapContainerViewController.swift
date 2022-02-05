//
//  RDCMiSnapContainerView.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/12/18.
//

import Foundation
import ComponentKit
import Localization
import SnapKit
#if canImport(MiSnap)
  import MiSnap
#endif

public final class RDCMiSnapContainerViewController: UIViewControllerComponent {
    
    @IBOutlet weak var containerView: UIView!
    
    var completionHandler: RDCCaptureCompletionHandler?
    
    var miSnapViewController: UIViewController?
    
    private var frontImageString: String?
    private var backImageString: String?
    private var viewControllerProvider: MiSnapViewControllerProvider
    
    var captureSide: RDCCaptureSide = .front
    private let captureType: RDCCaptureType
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscapeRight }
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                viewControllerProvider: MiSnapViewControllerProvider,
                captureType: RDCCaptureType = .both) {
        self.viewControllerProvider = viewControllerProvider
        self.captureType = captureType
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: MiSnapCommonBundle.bundle
        )
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        switch captureType {
        case .back:
            captureBackImage(animated: false)
        default:
            captureFrontImage(animated: false)
        }
    }
    
    private func captureFrontImage(animated: Bool) {
        captureSide = .front
        showCaptureViewController(side: captureSide, animated: animated)
    }
    
    private func captureBackImage(animated: Bool) {
        captureSide = .back
        showCaptureViewController(side: captureSide, animated: animated)
    }
    
    func showCaptureViewController(side: RDCCaptureSide, animated: Bool) {
        let captureViewController = viewControllerProvider.viewController(forSide: side, withDelegate: self)

        addCaptureViewController(viewController: captureViewController)
        removeExistingCaptureViewController()
        miSnapViewController = captureViewController
        
        guard animated else {
            return
        }
        
        UIView.transition(with: containerView, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
    
    private func addCaptureViewController(viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        viewController.view.snp.makeConstraints { (make) in
            make
                .edges
                .equalTo(containerView)
        }
    }
    
    private func removeExistingCaptureViewController() {
        guard let existingVC = miSnapViewController else {
            return
        }
        
        existingVC.willMove(toParent: nil)
        existingVC.removeFromParent()
        existingVC.view.removeFromSuperview()
    }
    
    private func processResults() {
        let captureImage = RDCCaptureImages(
            encodedFront: frontImageString ?? "",
            encodedBack: backImageString ?? ""
        )
        
        completionHandler?(captureImage)
    }
    
    func presentCaptureAlert(title: String,
                             message: String,
                             retryHandler: ((UIAlertAction) -> Void)?,
                             acceptHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: l10nProvider.localize("device.rdc.retake.btn"),
                style: .default,
                handler: retryHandler
            )
        )
        alert.addAction(
            UIAlertAction(
                title: l10nProvider.localize("device.rdc.use.btn"),
                style: .default,
                handler: acceptHandler
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
}

extension RDCMiSnapContainerViewController: MiSnapViewControllerDelegate {
    public func miSnapFinishedReturningEncodedImage(_ encodedImage: String!,
                                                    originalImage: UIImage!,
                                                    andResults results: [AnyHashable: Any]!) {
        if captureSide == .front {
            presentCaptureAlert(
                title: l10nProvider.localize("device.rdc.flip-check.title"),
                message: l10nProvider.localize("device.rdc.flip-check.message"),
                retryHandler: { [weak self] (_) in
                    self?.captureFrontImage(animated: false)
                },
                acceptHandler: { [weak self] (_) in
                    self?.frontImageString = encodedImage
                    if self?.captureType == .both {
                        self?.captureBackImage(animated: true)
                    } else {
                        self?.processResults()
                    }
                }
            )
        } else if captureSide == .back {
            presentCaptureAlert(
                title: l10nProvider.localize("device.rdc.back-captured.title"),
                message: l10nProvider.localize("device.rdc.back-captured.message"),
                retryHandler: { [weak self] (_) in
                    self?.captureBackImage(animated: false)
                },
                acceptHandler: { [weak self] (_) in
                    self?.backImageString = encodedImage
                    self?.processResults()
                }
            )
        }
    }
    
    public func miSnapCancelled(withResults results: [AnyHashable: Any]!) {
        completionHandler?(nil)
    }
}

extension RDCMiSnapContainerViewController: RDCServiceProtocol {
    public func setCaptureCompletion(completion: @escaping (RDCCaptureImages?) -> Void) {
        self.completionHandler = completion
    }
}
