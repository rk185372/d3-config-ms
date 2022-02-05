//
//  NoneCardControlManager.swift
//  CardControl
//
//  Created by Elvin Bearden on 2/1/21.
//

import Foundation
import CardControlApi
import RxSwift
import RxCocoa

public class NoneCardControlManager: CardControlManager {

    public var errorRelay: BehaviorRelay<CardControlError?> = BehaviorRelay(value: nil)

    public func setup() -> Observable<Void> { return .empty() }
    public func applicationLaunched(with options: [UIApplication.LaunchOptionsKey: Any]?) {}
    public func launchCardControls(loadingPresenter: UIViewController?) {}
}
