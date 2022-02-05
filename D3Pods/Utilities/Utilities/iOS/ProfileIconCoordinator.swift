//
//  ProfileIconCoordinator.swift
//  Utilities-iOS
//
//  Created by Branden Smith on 8/9/19.
//

import Foundation

public protocol ProfileIconCoordinator {
    var profileIconComponent: UIBarButtonItem { get }

    func setupForViewController(_ controller: UIViewController)
}

public protocol ProfileIconCoordinatorFactory {
    func create() -> ProfileIconCoordinator
}
