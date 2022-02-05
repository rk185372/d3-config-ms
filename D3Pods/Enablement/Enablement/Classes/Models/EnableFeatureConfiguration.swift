//
//  EnableFeatureConfiguration.swift
//  D3 Banking
//
//  Created by Branden Smith on 10/11/17.
//

import Foundation
import Network
import RxSwift
import LegalContent

public protocol EnableFeatureConfiguration {
    var image: UIImage { get }
    var helperText: String { get }
    var disclosureButtonTitle: String { get }
    var disableButtonTitle: String { get }
    var enableButtonTitle: String { get }
    var enableErrorAlertTitle: String { get }
    var enableErrorAlertMessage: String { get }
    var completionHandler: () -> Void { get }

    func enable() -> Completable
    func retrieveDisclosureText() -> Single<String>
}
