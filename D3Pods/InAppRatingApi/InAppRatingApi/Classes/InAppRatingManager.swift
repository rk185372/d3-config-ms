//
//  InAppRatingManager.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import RxSwift

public protocol InAppRatingManager {
    func obtainPromptStatus() -> Completable
    func engage(event: String, fromViewController viewController: UIViewController)
}
