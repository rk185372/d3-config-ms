//
//  TabBarBadgeMoreViewManager.swift
//  ComponentKit
//
//  Created by Jose Torres on 9/29/20.
//

import Foundation
import RxSwift

public enum BadgeMoreViewManagerType {
    case messages
    case alerts
    case approvals
}

public protocol BadgeMoreViewManager {
    func set(badgeMoreViewManager: TabBarBadgeMoreViewManager, type: BadgeMoreViewManagerType)
}

public final class TabBarBadgeMoreViewManager {
    public let badgeCount: Observable<Int>

    public let componentStyle: BadgeOnMoreNavigationStyle

    public init(badgeCount: Observable<Int>, styleProvider: ComponentStyleProvider) {
        self.badgeCount = badgeCount
        componentStyle = styleProvider[BadgeStyleKey.badgeOnMoreNavigation]
    }
}
