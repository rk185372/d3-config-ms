//
//  ApptentiveInAppRatingManager.swift
//  InAppRating
//
//  Created by Branden Smith on 8/26/19.
//

import Apptentive
import AppConfiguration
import CompanyAttributes
import Foundation
import InAppRatingApi
import Logging
import RxSwift

final class ApptentiveInAppRatingManager: InAppRatingManager {

    private let companyAttributesHolder: CompanyAttributesHolder
    private let bag = DisposeBag()

    init(companyAttributesHolder: CompanyAttributesHolder) {
        self.companyAttributesHolder = companyAttributesHolder
        self.companyAttributesHolder
            .companyAttributes
            .filter({ attributes in attributes != nil })
            .subscribe(onNext: { attributes in
                guard let apiKey: String = attributes?.value(forKey: "apptentive.api.key.ios") else { return }
                guard let apiSignature: String = attributes?.value(forKey: "apptentive.api.key.signature.ios") else { return }

                if let config = ApptentiveConfiguration(apptentiveKey: apiKey, apptentiveSignature: apiSignature) {
                    config.appID = AppConfiguration
                        .appStoreUrl
                        .lastPathComponent
                        .replacingOccurrences(of: "id", with: "")

                    Apptentive.register(with: config)
                }
            })
            .disposed(by: bag)
    }

    func obtainPromptStatus() -> Completable {
        return Completable.create { observer in
            observer(.completed)

            return Disposables.create()
        }
    }

    func engage(event: String, fromViewController viewController: UIViewController) {
        log.debug("Engaging event: \(event)")
        
        Apptentive.shared.engage(event: event, from: viewController)
    }
}
