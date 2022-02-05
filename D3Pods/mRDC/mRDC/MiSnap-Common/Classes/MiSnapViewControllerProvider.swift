//
//  MiSnapViewControllerProvider.swift
//  mRDC
//
//  Created by Branden Smith on 2/15/19.
//

import Foundation
import UIKit
import MiSnap

public protocol MiSnapViewControllerProvider {
    func viewController(forSide side: RDCCaptureSide, withDelegate delegate: MiSnapViewControllerDelegate) -> UIViewController
}
