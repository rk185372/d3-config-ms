//
//  InAppRatingManagerItem.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import RxSwift
import InAppRatingApi

final class InAppRatingManagerItem: InAppRatingManager {
    init() { }
    
    func obtainPromptStatus() -> Completable {
        return Completable.empty()
    }
    
    func promptUser(fromViewController viewController: UIViewController, event: String) -> Completable {
        return Completable.empty()
    }
}
