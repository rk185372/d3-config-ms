//
//  TabBarBadgeManager.swift
//  ComponentKit
//
//  Created by Branden Smith on 9/19/18.
//

import Foundation
import RxSwift

public protocol BadgeManager {
    func set(badgeManager: TabBarBadgeManager)
}

public final class TabBarBadgeManager {
    public let badgeCount: Observable<Int>

    public let componentStyle: BadgeOnTabBarStyle

    public init(badgeCount: Observable<Int>, styleProvider: ComponentStyleProvider) {
        self.badgeCount = badgeCount
        componentStyle = styleProvider[BadgeStyleKey.badgeOnTabBar]
    }
}
