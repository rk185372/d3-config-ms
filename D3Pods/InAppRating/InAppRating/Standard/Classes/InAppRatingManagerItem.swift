//
//  InAppRatingManagerItem.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import Localization
import Logging
import StoreKit
import RxSwift
import Network
import InAppRatingApi

final class InAppRatingManagerItem: InAppRatingManager {
    private var shouldPrompt: Bool = false
    private let service: InAppRatingService
    private let l10nProvider: L10nProvider

    private let eventWhiteList: [String] = [
        "RDC",
        "cardControls:toggled",
        "transfer:confirmed"
    ]
    
    init(service: InAppRatingService, l10nProvider: L10nProvider) {
        self.service = service
        self.l10nProvider = l10nProvider
    }
    
    func obtainPromptStatus() -> Completable {
        return service
            .shouldPrompt()
            .do(onSuccess: { [unowned self] response in
                self.shouldPrompt = response.shouldPrompt
            })
            .asCompletable()
    }

    func engage(event: String, fromViewController viewController: UIViewController) {
        promptUser(fromViewController: viewController, event: event).subscribe()
    }
    
    private func promptUser(fromViewController viewController: UIViewController, event: String) -> Completable {
        guard shouldPrompt && eventWhiteList.contains(event) else {
            return Completable.empty()
        }

        // To ensure user doesn't get more than one prompt in the same session
        self.shouldPrompt = false

        log.debug("Engaging event: \(event)")

        return Single<Int>
            .timer(1, scheduler: MainScheduler.instance)
            .flatMap { _ -> Single<Bool> in
                Single<Bool>.create { observer in
                    let alert = UIAlertController(
                        title: self.l10nProvider.localize("in-app-rating.prompt.title"),
                        message: self.l10nProvider.localize("in-app-rating.prompt.message"),
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(title: self.l10nProvider.localize("in-app-rating.prompt.no"), style: .default, handler: { _ in
                            observer(.success(false))
                        })
                    )
                    alert.addAction(
                        UIAlertAction(title: self.l10nProvider.localize("in-app-rating.prompt.yes"), style: .default, handler: { _ in
                            observer(.success(true))
                        })
                    )

                    viewController.present(alert, animated: true, completion: nil)

                    return Disposables.create()
                }
            }
            .do(onSuccess: { agreedToRate in
                if agreedToRate {
                    SKStoreReviewController.requestReview()
                }
            })
            .flatMapCompletable { agreedToRate -> Completable in
                let request = UserPromptedRequest(promptedLocation: event, agreedToRate: agreedToRate)
                return self.service.userPrompted(request)
            }
    }
}
