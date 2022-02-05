//
//  ViewControllerFactory.swift
//  Pods
//
//  Created by Andrew Watt on 6/28/18.
//

import UIKit

public protocol ViewControllerFactory {
    func create() -> UIViewController
}
