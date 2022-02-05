//
//  ReactiveFontObserver.swift
//  ComponentKit
//
//  Created by Chris Carranza on 4/30/18.
//

import Foundation
import RxSwift
import RxCocoa

/// A class for reactively acting upon UIContentSizeCategoryChange events for a given font.
final class ReactiveFontObserver {
    private let originalFont: BehaviorRelay<UIFont>
    
    let font: Driver<UIFont>
    
    init(originalFont: UIFont) {
        self.originalFont = BehaviorRelay(value: originalFont)
        
        let notificationObservable = NotificationCenter.default.rx.notification(UIContentSizeCategory.didChangeNotification)
        
        self.font = Observable.combineLatest(
            self.originalFont,
            notificationObservable.startWith(Notification(name: UIContentSizeCategory.didChangeNotification))
        ).map({ (observables) -> UIFont in
            let font = observables.0
            
            let maxFontSize = 2 * font.pointSize
            
            if #available(iOS 11, *) {
                return UIFontMetrics(forTextStyle: .body).scaledFont(for: font, maximumPointSize: maxFontSize)
            } else {
                let scalar = UIFont.preferredFont(forTextStyle: .body).pointSize / 17.0
                return font.withSize(min(maxFontSize, font.pointSize * scalar))
            }
        }).asDriver(onErrorJustReturn: self.originalFont.value)
    }
    
    func updateOriginalFont(font: UIFont) {
        originalFont.accept(font)
    }
}
