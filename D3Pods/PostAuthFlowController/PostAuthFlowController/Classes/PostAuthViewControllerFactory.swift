//
//  PostAuthViewControllerFactory.swift
//  PostAuthFlowController
//
//  Created by Branden Smith on 12/10/18.
//

import Foundation

public protocol PostAuthViewControllerFactory {
    func create(postAuthFlowController: PostAuthFlowController) -> UIViewController
}
