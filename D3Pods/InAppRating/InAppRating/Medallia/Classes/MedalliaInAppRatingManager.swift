//
//  MedalliaInAppRatingManager.swift
//  Accounts-iOS
//
//  Created by Jose Torres on 7/23/20.
//

import MedalliaDigitalSDK
import CompanyAttributes
import ComponentKit
import Foundation
import InAppRatingApi
import Logging
import RxSwift

struct MedalliaConfig: Decodable {
    let token: String
}

final class MedalliaInAppRatingManager: InAppRatingManager {
    
    private let companyAttributesHolder: CompanyAttributesHolder
    private let bag = DisposeBag()
    private let token = createConfigFromBundle().token
    private var formID: String?
    
    public init(companyAttributesHolder: CompanyAttributesHolder) {
        self.companyAttributesHolder = companyAttributesHolder
        
        MedalliaDigital.sdkInit(
            token: token,
            success: {
                log.debug("MedalliaDigitalSDK init success")
        },
            failure: { error in
                log.error(error)
        })
        
        NotificationCenter.default.rx.notification(.notPresentViewControllerSelected)
            .filterMap(transform: { $0.object as? NotPresentViewController.ActionKey })
            .filterMap(transform: { $0 == .medalliaDigitalSDK })
            .subscribe(onNext: { [unowned self] (isMedallia) in
                if isMedallia {
                    self.presentForm()
                }
            })
            .disposed(by: bag)
        
        self.companyAttributesHolder
            .companyAttributes
            .filter({ attributes in attributes != nil })
            .subscribe(onNext: { attributes in
                self.formID = attributes?.value(forKey: "medallia.form.id.ios")
        })
        .disposed(by: bag)
    }
    
    private static func createConfigFromBundle() -> MedalliaConfig {
        guard let configPath = MedalliaBundle.bundle.url(forResource: "MedalliaProperties", withExtension: "json") else {
            fatalError("Missing config file for Medallia.")
        }

        let decoder = JSONDecoder()
        let url = configPath
        let contents = try! Data(contentsOf: url)

        return try! decoder.decode(MedalliaConfig.self, from: contents)
    }
    
    func obtainPromptStatus() -> Completable {
        return Completable.create { observer in
            observer(.completed)
            return Disposables.create()
        }
    }

    func engage(event: String, fromViewController viewController: UIViewController) {
        log.debug("Engaging event: \(event)")
        MedalliaDigital.setCustomParameter(name: event, value: true)
    }
    
    private func presentForm() {
        guard let formID = formID else { return }
        MedalliaDigital.showForm(
            formID,
            success: {
                log.debug("MedalliaDigital form showed successfully")
        },
        failure: { error in
            log.error(error)
        })
    }
}
