//
//  WebViewController+QRScanner.swift
//  Web
//
//  Created by Pablo Pellegrino on 22/12/2021.
//

import Foundation
import QRScanner
import Localization

extension WebViewController {
    final class QRScannerPresenter: QRScannerViewControllerDelegate {
        private let webClient: WebClient
        private let l10nProvider: L10nProvider
        private let qrScannerFactory: QRScannerViewControllerFactory
        private var qrScannerViewController: UIViewController!
        private var onQRScanned: ((String) -> Void)?
        private var onQRScanError: ((Error?) -> Void)?
        
        init(webClient: WebClient,
             qrScannerFactory: QRScannerViewControllerFactory,
             l10nProvider: L10nProvider) {
            self.webClient = webClient
            self.qrScannerFactory = qrScannerFactory
            self.l10nProvider = l10nProvider
        }
        
        func showQRScanner(mode: QRScannerViewControllerMode,
                           profilesData: [[String: Any]],
                           on controller: UIViewController,
                           onQRScanned: @escaping (String) -> Void,
                           onQRScanError: @escaping (Error?) -> Void) {
            let profileModels = profilesData.map {
                ProfileQRCodeDataModel(userId: $0["loginId"] as? String ?? "",
                                       username: $0["name"] as? String ?? "",
                                       userPic: UIImage(named: "UserProfile"),
                                       qrData: ZelleQRDataModel(name: $0["name"] as? String ?? "",
                                                                token: $0["token"] as? String ?? ""))
            }
            
            let qrCodeValidator = ZelleQRInfoBuilder(userProfileQRTokens: profileModels.map { $0.qrData.token }, l10nProvider: l10nProvider)
            qrScannerViewController = qrScannerFactory.create(model: QRScannerViewControllerModel(profilesData: profileModels,
                                                                                                  validator: qrCodeValidator,
                                                                                                  mode: mode),
                                                              delegate: self)
            self.onQRScanned = onQRScanned
            self.onQRScanError = onQRScanError
            controller.present(qrScannerViewController, animated: true)
        }
        
        public func didScanQRCode(withData data: ZelleQRDataModel) {
            qrScannerViewController.dismiss(animated: true) { [weak self] in
                guard let responseData = try? ["name": data.name, "token": data.token].encode(),
                let response = try? String(jsonData: responseData) else {
                    return
                }
                self?.onQRScanned?(response)
            }
        }
        
        public func didFailScanningQRCode(withError error: Error?) {
            qrScannerViewController.dismiss(animated: true)
            onQRScanError?(error)
        }
    }

}
