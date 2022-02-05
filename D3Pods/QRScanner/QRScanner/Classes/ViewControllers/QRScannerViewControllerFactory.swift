//
//  QRScannerViewControllerFactory.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 20/12/2021.
//

import Foundation
import Localization

public class QRScannerViewControllerFactory {
    private let utils: QRCodeUtils
    private let l10nProvider: L10nProvider
    
    public init(utils: QRCodeUtils, l10nProvider: L10nProvider) {
        self.utils = utils
        self.l10nProvider = l10nProvider
    }
    
    public func create< QRValidatorType: ProfileQRCodeInfoBuilder,
                        DelegateType: QRScannerViewControllerDelegate >(model: QRScannerViewControllerModel<QRValidatorType>,
                                                                        delegate: DelegateType? = nil)
    -> QRScannerViewController<QRValidatorType, DelegateType> {
        return QRScannerViewController(model: model, utils: utils, l10nProvider: l10nProvider, delegate: delegate)
    }
}
