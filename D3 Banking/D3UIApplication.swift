//
//  D3UIApplication.swift
//  D3 Banking
//
//  Created by Branden Smith on 8/29/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

final class D3UIApplication: UIApplication {
    fileprivate let _touchRelay = BehaviorRelay<UIEvent>(value: UIEvent())
    fileprivate let _shakeRelay = PublishRelay<UIEvent>()

    override func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            _touchRelay.accept(event)
        }

        if event.subtype == .motionShake {
            _shakeRelay.accept(event)
        }

        super.sendEvent(event)
        
    }
}

extension Reactive where Base == D3UIApplication {
    var touchEvents: Observable<UIEvent> {
        return base._touchRelay.skip(1).asObservable()
    }

    var shakeEvents: Observable<UIEvent> {
        return base._shakeRelay.asObservable()
    }
}
