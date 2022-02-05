//
//  ContentViewFactory.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import Foundation

protocol ContentViewFactory {
    func create() -> UIViewController & ContentViewController
}
