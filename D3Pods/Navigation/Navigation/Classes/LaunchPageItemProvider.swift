//
//  LaunchPageItemProvider.swift
//  Navigation
//
//  Created by Andrew Watt on 8/2/18.
//

import Foundation
import RxSwift

public protocol LaunchPageItemProvider {
    var launchPageItemsObservable: Observable<[LaunchPageItem]> { get }
}
